[cmdletbinding()]
param(
  [Parameter(Mandatory=$true,Position=1)]
  [string]$EnvFile
)

# TODO: module dependency

$ErrorActionPreference = "Stop"

$env:PGDATABASE="manual"

if(Test-Path $EnvFile)
{
  Write-Host "Loading ${EnvFile}"
  Get-Content $EnvFile | ForEach-Object {
    $name, $value = $_.split('=')
    if ([string]::IsNullOrWhiteSpace($name) -or $name.Contains('#')) { return }
    Set-Content env:\$name $value
  }
}
else
{
  Write-Error "$EnvFile not found"
}

# TODO: run $PSScriptRoot/setup.sql against `postgres` twice (staging if variables set, and $env:PGDATABASE)
