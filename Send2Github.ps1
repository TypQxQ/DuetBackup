# Based on Oneshot Duet Backup and modified by Andrei Ignat

#region user defined
$workingFolder = ('{0}\DuetBackup' -f [Environment]::GetFolderPath("MyDocuments")) 
#endregion

#region send to GitHub
Set-Location -Path $workingFolder
git add .
git commit -m "Backup"
git push -f
#endregion