$ErrorActionPreference = "Stop"
$InformationPreference = "Continue"
$WarningPreference = "Continue"

# TODO: convert to Pester suite

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
  $query = "SELECT * FROM pg_roles"
  
  foreach($mode in (Get-Command "Invoke-PostgresCmd").Parameters["OutputType"].Attributes.ValidValues)
  {
    Write-Host ("=" * 80)
    Write-Host $mode
    $value = Invoke-PostgresCmd $conn $query $mode
    if($value)
    {
      Write-Host $value.GetType()
      $value | Format-Table
    }
    else
    {
      Write-Host "Null`n"
    }
    Clear-Variable "value"
  }
}
catch 
{
  Write-Error "❌ Database operation failed: $_"
}
finally
{
  $conn.Close()
}


Backup-PostgresDatabase



