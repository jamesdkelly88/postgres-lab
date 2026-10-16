<#
.SYNOPSIS
Returns a PostgreSQL ODBC connection (without a database name)
#>
function Get-PostgresConnectionString {
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword","")]
  param(
      [Parameter(Position = 0)]
      [string]$Server = $env:PGHOST,
      [Parameter(Position = 1)]
      [string]$Username = $env:PGUSER,
      [Parameter(Position = 2)]
      [string]$Password = $env:PGPASSWORD,
      [Parameter(Position = 3)]
      [int]$Port = $env:PGPORT,
      [Parameter(Position = 4)]
      [string]$SslMode = $env:PGSSLMODE,
      [Parameter(Position = 5)]
      [string]$OdbcDriver = ""
  )

  if([String]::IsNullOrEmpty($OdbcDriver))
  {
    $drivers = if ($IsWindows) { (Get-OdbcDriver).Name } else { odbcinst -q -d | ForEach-Object { $_.Trim('[', ']') } }
    $OdbcDriver = $drivers.Where{ $_.ToUpper() -like "*POSTGRES*"}[0]
  }
  if([String]::IsNullOrEmpty($OdbcDriver)){ throw "Driver not specified or found from installed options" }
  if([String]::IsNullOrEmpty($Server)) { throw "Server required" }
  if([String]::IsNullOrEmpty($Username)) { throw "Username required" }
  if([String]::IsNullOrEmpty($Password)) { throw "Password required" }
  if(-not $Port -or $Port -le 0) { $Port = 5432 }
  if([String]::IsNullOrEmpty($SslMode)) { $SslMode = "prefer" }

  return [String]::Join(";",@(
    "Driver={${OdbcDriver}}",
    "Server=${Server}",
    "Port=${Port}",
    "Uid=${Username}",
    "Pwd=${Password}",
    "sslmode=${SslMode}"
  ))

}