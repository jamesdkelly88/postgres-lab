function Import-EnvFile {
  param(
      [Parameter(Position = 0)]
      [string]$Path = ".env"
  )
  
  if (Test-Path $Path) {
    Write-Information "Importing from $Path"
    $c = 0
    Get-Content $Path | ForEach-Object {
      $line = $_.Trim()
      if ($line -and !$line.StartsWith('#') -and $line.Contains('=')) {
        $key, $value = $line -split '=', 2
        $key = $key.Trim()
        $value = $value.Trim().Trim("'").Trim('"')
        Write-Verbose "Setting environment variable $key"
        [System.Environment]::SetEnvironmentVariable($key, $value, "Process")
        $c++
      }
    }
    Write-Information "Imported $c variables"
  }
  else
  {
    Write-Warning "$Path not found"
  }
}