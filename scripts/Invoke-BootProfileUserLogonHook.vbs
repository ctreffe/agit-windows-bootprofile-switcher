Option Explicit

Dim shell, fileSystem, scriptDirectory, hookScript, command

Set shell = CreateObject("WScript.Shell")
Set fileSystem = CreateObject("Scripting.FileSystemObject")

scriptDirectory = fileSystem.GetParentFolderName(WScript.ScriptFullName)
hookScript = fileSystem.BuildPath(scriptDirectory, "Invoke-BootProfileUserLogonHook.ps1")
command = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & hookScript & """ -DelaySeconds 30"

shell.Run command, 0, True
