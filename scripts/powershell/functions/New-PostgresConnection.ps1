function New-PostgresConnection {
  param(
    [Parameter(Mandatory,Position=0)]
    [String]$ConnectionString,
    [Parameter(Mandatory,Position=1)]
    [String]$Database
  )

  $conn = New-Object System.Data.Odbc.OdbcConnection
  $conn.ConnectionString = "${ConnectionString};Database=${Database}"
  $conn.Open()

  return $conn
}

