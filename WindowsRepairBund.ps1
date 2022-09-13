
$title    = 'Starting Administrative Windows Repairs'
$question = 'Are you sure you want to proceed?'
$choices  = '&Yes', '&No'
$title2 = 'Would you like to install the new version of Powershell?'
$title3 = 'Are you on windows 10?'
$title4 = 'Would you like to create a restore point?'
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -executionpolicy bypass -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}
$decision = $Host.UI.PromptForChoice($title3, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
    $url2 = "https://go.microsoft.com/fwlink/?LinkID=799445"
    $folder2 = "$env:appdata\WUA"

if (Test-Path -Path $folder2) {Write-Host "WUA directory already exists, removing old version"
    Remove-Item -Path $folder2 -Recurse
    New-Item -Path "$env:appdata\" -Name "WUA" -ItemType "directory"
    Invoke-WebRequest $url2 -OutFile "$folder2\WUA.exe"
    Start-Process "$folder2\WUA.exe"
}
else {
    New-Item -Path "$env:appdata\" -Name "WUA" -ItemType "directory"
    Invoke-WebRequest $url2 -OutFile "$folder2\WUA.exe"
    Start-Process "$folder2\WUA.exe"}
}
else {
    Write-Host 'cancelled'
}
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
Repair-WindowsImage -Online -Restorehealth -Startcomponentcleanup -ResetBase
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Start-Process -FilePath "${env:Windir}\System32\cmd.EXE" -ArgumentList '/c sfc /scannow' -Wait -Verb RunAs
} 
else {
    Write-Host 'cancelled'
}
$decision = $Host.UI.PromptForChoice($title2, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
$url3 = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.6/PowerShell-7.2.6-win-x64.msi"
$folder3 = "$env:Temp\pwsh"
if (Test-Path -Path $folder3) { Write-Host "pwsh directory already exists, skipping" }
else {
New-Item -Path "$env:temp\" -Name "pwsh" -ItemType "directory"
Invoke-WebRequest  $url3 -OutFile "$folder3\pwsh.msi"
Start-Process "$folder3\pwsh.msi" -ArgumentList "/quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ENABLE_PSREMOTING=0 REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1"}
}
else {
    Write-Host 'cancelled'
}
$decision = $Host.UI.PromptForChoice($title4, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
$a = Get-Date
try {Enable-ComputerRestore -drive C:\
Invoke-CimMethod -Namespace  root/DEFAULT -ClassName SystemRestore -MethodName CreateRestorePoint -Arguments @{
    Description      = (Get-Date).ToString()
    RestorePointType = [uint32]0
    EventType        = [uint32]100
}
}
catch { "unable to create restore point, starting gui"}
Start-Process -Filepath "${env:Windir}\System32\rstrui.exe"
Start-Process -Filepath "${env:Windir}\System32\SystemPropertiesProtection.exe"
}
else {
Write-Host 'cancelled'
}

