
$SqlServer = “Server_Name”
$SqlCatalog = “DataBase_Name”
$SqlQuery = @”
SELECT *
FROM Employees 
“@
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = “Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True”
$SqlConnection.Open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

foreach ($Row in $dataset.Tables[0].Rows) { 
	write-Output "$($Row.First_Name)"
	write-Output "$($Row.Last_Name)"
}
