$PathToCsvRepos = "${HOME}/.repos.csv"
$repo_compiler = [RepoCLI]::new()

function Test-RepoDataPath
{
    if (-not (Test-Path $RepoPath))
    {
        New-Item -Path $RepoPath -ItemType File
    }
}

function Add-RepoCLI
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $repoName,

        [string] $repoPath = (Get-Location).Path
    )
    try
    {
        write-host "Debug: $repoName, $repoPath" 
        $repos = Import-Csv $RepoPath -Delimiter ','
        if ($repos | Where-Object { $_.RepoName -eq $repoName })
        {
            Write-Host "Repo already exists"
            return
        }
        $repos += [PSCustomObject]@{
            RepoName = $repoName
            RepoPath = $repoPath
        }
        $repos | Export-Csv $RepoPath -Delimiter ',' -Append -NoTypeInformation
        write-host "Repo added successfully"
        write-host "Debug: $repos"
        $repo_compiler.SetRepoData($repos)
        $repo_compiler.Build()
    } catch
    {
        # Write-Host "Repo not found $_}"
        Write-Host "$_"
    }

}
function Get-RepoCLI
{
    try
    {
        $repos = Import-Csv $RepoPath -Delimiter ','
        return $repos
    } catch
    {
        Write-Host "Repo not found ${_.Exception.Message}"
    }

}
function Remove-RepoCLI
{
    param (
        [Parameter(Mandatory = $true)]
        [string] $repoName
    )
    try
    {
        $repos = Get-RepoCLI | Where-Object { $_.RepoName -ne $repoName }
        # $repo.Remove($repoName)
        # $repos = $repos | Where-Object { $_.RepoName -ne $repoName }
        $repos | Export-Csv $RepoPath -Delimiter ',' -NoTypeInformation
        $repo_compiler.SetRepoData($repos)
        $repo_compiler.Build()
    } catch
    {
        Write-Host "Repo not found ${_.Exception.Message}"
    }

}
function Edit-RepoCLI
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $repoName,

        [string] $repoPath = $PWD,

        [string] $NewRepoName,

        [switch] $OnlyName = $false
    )
    try
    {
        $repo = Get-RepoCLI | Where-Object { $_.RepoName -eq $repoName }
        if ($repo)
        {
            if ($OnlyName)
            {
                $repo.RepoName = $NewRepoName
            }
            if (-not (Test-Path $repoPath))
            {
                Write-Host "Repo path not found"
                return
            }
            if ($OnlyName -and $NewRepoName)
            {
                $repo.RepoName = $NewRepoName
                $repo.RepoPath = $repoPath
            } else
            {
                $repo.RepoPath = $repoPath
            }
            $repos = Get-RepoCLI | Where-Object { $_.RepoName -ne $repoName }
            $repos += $repo
            $repos | Export-Csv $RepoPath -Delimiter ',' -NoTypeInformation
        } else
        {
            Write-Host "Repo not found"
        }
        $repo_compiler.SetRepoData($repos)
        $repo_compiler.Build()
    } catch
    {
        Write-Host "Repo not found ${_.Exception.Message}"
    }

}

class RepoCLI
{
    [array] $RepoData
    [string] $CliPath = "$env:MY_CD_CLI_PATH"

    [void] Build()
    {
        if ($this.ValidCliPath() -eq $false)
        {
            return
        }

        $repoNames_Array = $this.RepoData | ForEach-Object { $_.RepoName }
        $repoNames = $repoNames_Array -join "','"

        Set-Content -Path $this.CliPath -Value @"
param (
    [ValidateSet('${repoNames}')]
    [string] `$repoName = "NoRepo

    inProvided"
)
try {
    `$repo = @{
"@
        foreach ($repo in $this.RepoData)
        {
            $repoName = $repo.RepoName
            $repoPath = $repo.RepoPath
            Add-Content -Path $this.CliPath -Value "`"${repoName}`" = `"${repoPath}`""
        }
        Add-Content -Path $this.CliPath -Value @"
    }
    if (-not `$repo.ContainsKey(`$repoName)) {
        throw "Repo not found"
    }
    `$repoPath = `$repo[`$repoName]
    cd `$repoPath
} catch {
    Write-Host "Repo not found"
}
"@

    }

    [bool] ValidCliPath ()
    {
        if ("" -eq $this.CliPath)
        {
            Write-Host "Cli path is not set"
            return $false
        }
        if (-not (Test-Path $this.CliPath))
        {
            Write-Host "Cli path is not valid"
            return $false
        }
        return $true
    }

    [void] SetRepoData ([array] $RepoData)
    {
        $this.RepoData = $RepoData
    }

}
