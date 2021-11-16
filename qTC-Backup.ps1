#region user defined
$workingFolder = ('{0}\DuetBackup' -f [Environment]::GetFolderPath("MyDocuments")) 
$rfmDownloadUrl = 'https://github.com/wilriker/rfm/releases/download/v1.1.1/rfm-windows_amd64.zip'
$rfmOutputDestination = ('{0}\{1}' -f "$workingFolder\rfm", (Split-Path $rfmDownloadUrl -Leaf))


$railCoreHostOrIp = '192.168.1.210'
$printerName = 'qTC'

$backupDestination = ('{0}\{1}-backup' -f $workingFolder, $printerName)
#$backupDestination = ('{0}\{1}-backup-{2}' -f $workingFolder, $printerName, (Get-Date -Format 'MMddyy'))
#endregion

#region Only download rfm if not present

if (-NOT ([IO.Directory]::Exists($workingFolder))) {
    $null = New-Item -ItemType Directory -Path $workingFolder
}

if (-NOT ([IO.Directory]::Exists("$workingFolder\rfm"))) {
    $null = New-Item -ItemType Directory -Path "$workingFolder\rfm"
}

$rfmExists = Test-Path -Path "$workingFolder\rfm\rfm.exe"
if (-not $rfmExists) {
    Invoke-WebRequest -Uri $rfmDownloadUrl -OutFile $rfmOutputDestination -Verbose
    if (-NOT (Get-Item $rfmOutputDestination)) {
        $msg = ('Unable to find "{0}", unable to continue' -f $rfmOutputDestination)
        Write-Warning $msg
        Break
    }
    Expand-Archive -Path $rfmOutputDestination -DestinationPath "$workingFolder\rfm" -Force
    Remove-Item -LiteralPath $rfmOutputDestination -Force
}
#endregion

#region rfmExecution
$rfmParams = @(
    'backup'
    "-domain"
    $railCoreHostOrIp
    '-exclude'
    '0:/gcodes'
    '-exclude'
    '0:/www'
    '-exclude'
    '0:/firmware'
    $backupDestination
    '0:/'
    
)
if ([IO.Directory]::Exists($backupDestination)) {
    Remove-Item -LiteralPath $backupDestination -Force -Recurse
}
$null = New-Item -ItemType Directory -Path $backupDestination


#Start-Process $workingFolder"\rfm.exe" -Wait -ArgumentList $rfmParams -NoNewWindow -RedirectStandardOutput $env:APPDATA\stdout.txt -RedirectStandardError $env:APPDATA\stderr.txt
#Get-Content $env:APPDATA\stderr.txt
#endregion


#region send to GitHub
try {
    Set-Location -Path $workingFolder
    git add .
    git commit -m "Backup"
    git push -f
} catch {
    Throw
}
#endregion