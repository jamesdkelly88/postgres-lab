function Invoke-PostgresCmd {
  [CmdletBinding(DefaultParameterSetName = 'Table')]
  [OutputType([System.Data.DataTable], ParameterSetName='Table')]

  param(
    [Parameter(Mandatory, Position = 0)]
    [System.Data.Odbc.OdbcConnection]$Connection,
    [Parameter(Mandatory, Position = 1)]
    [String]$Query,
    [Parameter(Position = 2)]
    [ValidateSet("DataSet","Table","Scalar","Object","List","Array","None")]
    $OutputType = "Table",
    [Parameter(Position = 3)]
    [Int32]$QueryTimeout = 30
  )

  $cmd = New-Object System.Data.Odbc.OdbcCommand($Query,$Connection)
  $cmd.CommandTimeout = $QueryTimeout

  $ds = New-Object System.Data.DataSet
  (New-Object System.Data.Odbc.OdbcDataAdapter($cmd)).Fill($ds) | Out-Null

  if($OutputType -eq "None")
  {
    return $null
  }

  if($OutputType -eq "DataSet")
  {
    return $ds
  }

  $dt = $ds.Tables[0]

  if($OutputType -in @("Scalar","List") -and $dt.Rows.Count -eq 0)
  {
    return $null
  }

  if($OutputType -eq "Scalar")
  {
    return $dt.Rows[0][0]
  }

  if($OutputType -eq "List")
  {
    return $dt.foreach{ $_[0] }
  }

  if($OutputType -in @("Object","Array"))
  {
    $Objects = @()
    foreach($r in $dt.Rows)
    {
      $Properties = [ordered]@{}
      For($i = 0; $i -le $r.ItemArray.Count -1; $i++)
      {
        $Properties.Add($dt.Columns[$i].ColumnName, $r.ItemArray[$i])
      }
      $Objects += New-Object -TypeName PSObject -Property $Properties
      if($OutputType -eq "Object") { break } # Only first row required
    }

    if($OutputType -eq "Object")
    {
      return $Objects[0]
    }
    else
    {
      return ,$Objects
    }
  }

  # return DataTable 
  return ,$dt

}