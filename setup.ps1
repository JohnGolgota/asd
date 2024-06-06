
# Obtener la ruta del directorio donde se encuentra el script en ejecuci�n
$scriptRoot = $PSScriptRoot

# Construir la ruta completa del directorio 'bin' dentro del directorio del script
$binDirectory = Join-Path -Path $scriptRoot -ChildPath 'bin'

. $binDirectory\Repo.Utils.ps1

Test-RepoDataPath

# Obtener el valor actual del PATH del Registro de PowerShell
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

# Agregar el directorio 'bin' al PATH si no esta presente ya
if ($currentPath -notlike "*$binDirectory*") {
    $newPath = "$currentPath;$binDirectory"

    [Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine')
    
    Write-Host "Se ha agregado '$binDirectory' al PATH del Registro de PowerShell correctamente."

    Add-Content -Path $PROFILE -Value @"
. Repo.Utils.ps1
"@

}
else {
    Write-Host "'$binDirectory' ya esta presente en el PATH del Registro de PowerShell."
}

