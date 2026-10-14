function Invoke-PostgresCmd {
  [CmdletBinding(DefaultParameterSetName = 'Table')]
  [OutputType([System.Data.DataTable], ParameterSetName='Table')]

  param(
    [Parameter(Mandatory, Position = 0)]
    [System.Data.Odbc.OdbcConnection]$Connection,
    [Parameter(Mandatory, Position = 1)]
    [String]$Query,
    [Parameter(Position = 2)]
    [ValidateSet("DataSet","Table","Scalar","Object","List","Array")]
    $OutputType = "Table",
    [Parameter(Position = 3)]
    [Int32]$QueryTimeout = 30
  )

  $cmd = New-Object System.Data.Odbc.OdbcCommand($Query,$Connection)
  $cmd.CommandTimeout = $QueryTimeout

  $ds = New-Object System.Data.DataSet
  (New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).Fill($ds) | Out-Null

  if($OutputType -eq "DataSet")
  {
    return $ds
  }
  $dt = $ds.Tables[0]

  if($OutputType -eq "Scalar")
  {
    if($dt.Rows.Count -gt 0)
    {
      return $dt.Rows[0][0]
    }
    else
    {
      return $null
    }
  }

 
  # return DataTable 
  return ,$dt

}