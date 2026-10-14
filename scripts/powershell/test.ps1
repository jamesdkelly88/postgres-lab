$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

foreach($f in Get-ChildItem "$PSScriptRoot/functions/*.ps1")
{
  . $f.FullName
}

Import-EnvFile .env

$cs = Get-PostgresConnectionString

$cs

if(-not $conn)
{
  $conn = New-PostgresConnection $cs "postgres"
}
if($conn.State -eq 'Closed')
{
  $conn.Open()
}

try 
{
  $version = Invoke-PostgresCmd $conn "SELECT version();" Scalar
  $version
}
catch 
{
  Write-Error "❌ Database operation failed: $_"
}
finally
{
  $conn.Close()
}






