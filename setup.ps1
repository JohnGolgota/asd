
# Obtener la ruta del directorio donde se encuentra el script en ejecuci—n
$scriptRoot = $PSScriptRoot

# Construir la ruta completa del directorio 'bin' dentro del directorio del script
$binDirectory = Join-Path -Path $scriptRoot -ChildPath 'bin'

# Obtener el valor actual del PATH del Registro de PowerShell
$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")

# Agregar el directorio 'bin' al PATH si no est‡ presente ya
if ($currentPath -notlike "*$binDirectory*")
{
    $newPath = "$currentPath;$binDirectory"
    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
    
    Write-Host "Se ha agregado '$binDirectory' al PATH del Registro de PowerShell correctamente."
} else
{
    Write-Host "'$binDirectory' ya esta presente en el PATH del Registro de PowerShell."
}

