# Chemin vers le script PowerShell que vous souhaitez exécuter
$powerShellScriptPath = "C:\Path_To_Ps1_File\Forbidden_bg.ps1"

# Nom de la tâche planifiée
$taskName = "Your_Task_Name"

# Créer la tâche planifiée
$taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $powerShellScriptPath"
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $taskAction -Trigger $taskTrigger -TaskName $taskName
