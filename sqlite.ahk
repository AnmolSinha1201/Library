class SQLiteDB
{
	SQLiteDLLPath := "sqlite3.dll"
	__New(DBPath)
	{
		DllCall("LoadLibrary", "str", this.SQLiteDLLPath)
		
		VarSetCapacity(FileName, StrPut(DBPath, "UTF-8"))
		StrPut(DBPath, &FileName, "UTF-8")
		this.ModuleHandle := DllCall("sqlite3\sqlite3_open", "int", &FileName, "int*", DB)
		this.DBHandle := DB
	}
	
	__Delete()
	{
		RC := DllCall("sqlite3\sqlite3_close", "int", this.DBHandle)
		While(RC)
		{
			Stmt := DllCall("sqlite3\sqlite3_next_stmt", "int", this.DBHandle, "int", "NULL")
			DllCall("sqlite3\sqlite3_finalize", "int", Stmt)
			RC := DllCall("sqlite3\sqlite3_close", "int", this.DBHandle)
		}
		DllCall("Freelibrary", "int", this.ModuleHandle)
	}
		
	ExecQuery(Query)
	{
		VarSetCapacity(Dummy, StrPut(Query, "UTF-8"))
		Len := StrPut(Query, &Dummy, "UTF-8")
		if(!InStr(Query, "Select"))
			if(Ret := DllCall("sqlite3\sqlite3_exec", "int", this.DBHandle, "int", &Dummy, "int", 0, "int", 0, "int*", Err))
				return, StrGet(Err, "UTF-8")
			else
				return, Ret
		
		DllCall("SQlite3\sqlite3_prepare", "int", this.DBHandle, "int", &Dummy, "int", Len, "int*", Query, "int*", pSQL)
		DllCall("SQlite3\sqlite3_step", "int", Query)
		ColumnCount := DllCall("SQlite3\sqlite3_column_count", "int", Query)
		
		SQLite_Done := 101
		Table := Object()
		While(StepResult != SQLite_Done)
		{
			RowNo := A_Index
			Loop, % ColumnCount
			{
				strPtr := DllCall("SQlite3\sqlite3_column_text", "int", Query, "int", A_Index - 1)
				Table[RowNo, A_Index]:= StrGet(strPtr, "UTF-8")
			}
			StepResult := DllCall("SQlite3\sqlite3_step", "int", Query)
		}
		return, Table
	}
	
	GetColumnNames(TableName)
	{
		Query := "SELECT * FROM " TableName
		VarSetCapacity(Dummy, StrPut(Query, "UTF-8"))
		Len := StrPut(Query, &Dummy, "UTF-8")
		DllCall("SQlite3\sqlite3_prepare", "int", this.DBHandle, "int", &Dummy, "int", Len, "int*", Query, "int*", pSQL)
		
		ColumnCount := DllCall("SQlite3\sqlite3_column_count", "int", Query)
		
		ColumnNames := Object()
		Loop, % ColumnCount
		{
			strPtr := DllCall("SQlite3\sqlite3_column_name", "int", Query, "int", A_Index - 1)
			ColumnNames.Insert(StrGet(strPtr, "UTF-8"))
		}
		return, ColumnNames
	}
}
