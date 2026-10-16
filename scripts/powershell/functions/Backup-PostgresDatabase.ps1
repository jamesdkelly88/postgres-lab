function Backup-PostgresDatabase {
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
      [string]$PgDumpPath = ""
  )

  if([String]::IsNullOrEmpty($PgDumpPath))
  {
    $PgDumpPath = (Get-Command "pg_dump").Path
  }
  if([String]::IsNullOrEmpty($PgDumpPath) -or -not (Test-Path $PgDumpPath)){ throw "pg_dump not found" }
  if([String]::IsNullOrEmpty($Server)) { throw "Server required" }
  if([String]::IsNullOrEmpty($Username)) { throw "Username required" }
  if([String]::IsNullOrEmpty($Password)) { throw "Password required" }
  if(-not $Port -or $Port -le 0) { $Port = 5432 }
  if([String]::IsNullOrEmpty($SslMode)) { $SslMode = "prefer" }

  try
  {
    $env_ssl_mode = $env:PGSSLMODE
    $env:PGSSLMODE = $SslMode
    . $PgDumpPath -V
  }
  catch
  {
    throw $_
  }
  finally
  {
    $env:PGSSLMODE = $env_ssl_mode
  }
}