' FarmOS Auto-Start Script
' This script automatically starts the FarmOS server when the folder is opened

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' Get the current directory (where this script is located)
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

' Check if server is already running
On Error Resume Next
Set http = CreateObject("MSXML2.XMLHTTP")
http.open "GET", "http://127.0.0.1:8000/health", False
http.send

If Err.Number = 0 And http.Status = 200 Then
    ' Server is already running
    WScript.Quit
End If
On Error GoTo 0

' Start the FarmOS server
batchFile = currentDir & "\start_farmos.bat"
If fso.FileExists(batchFile) Then
    ' Run the batch file hidden
    WshShell.Run chr(34) & batchFile & chr(34), 0, False
End If
