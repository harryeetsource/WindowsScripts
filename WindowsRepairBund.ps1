
$title    = 'Starting Administrative Windows Repairs'
$question = 'Are you sure you want to proceed?'
$choices  = '&Yes', '&No'
$title2 = 'Would you like to install the new version of Powershell?'
$title3 = 'Are you on windows 10?'
$title4 = 'Would you like to create a restore point?'
$title5 = 'Would you like to repair windows update services?'
$url2 = "https://go.microsoft.com/fwlink/?LinkID=799445"
$folder2 = "$env:appdata\WUA"
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

if (Test-Path -Path $folder2) {Write-Host "WUA directory already exists, removing old version"
    Remove-Item -Path $folder2 -Recurse
    New-Item -Path "$env:appdata\" -Name "WUA" -ItemType "directory"
    Invoke-WebRequest $url2 -OutFile "$folder2\WUA.exe"
    Start-Process "$folder2\WUA.exe"}
    else {
        New-Item -Path "$env:appdata\" -Name "WUA" -ItemType "directory"
        Invoke-WebRequest $url2 -OutFile "$folder2\WUA.exe"
        Start-Process "$folder2\WUA.exe"}
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
$registrykey = "HKLM:\System\CurrentControlSet\Services\VSS\VssAccessControl"
$name = "$env:UserDomain\$env:UserName"
$value = "1"
$decision = $Host.UI.PromptForChoice($title4, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed, attempting to create restore point'
    try {Enable-ComputerRestore -drive C:\
	Invoke-CimMethod -Namespace  root/DEFAULT -ClassName SystemRestore -MethodName CreateRestorePoint -Arguments @{
    Description      = (Get-Date).ToString()
    RestorePointType = [uint32]0
    EventType        = [uint32]100
}}

    catch { "unable to create restore point, starting gui and adding manual registry key"
	Start-Process -Filepath "${env:Windir}\System32\rstrui.exe"
	Start-Process -Filepath "${env:Windir}\System32\SystemPropertiesProtection.exe"}
    if (test-path -path $registrykey){
	Write-host "user already has VSS service access" }
    else { New-Item -path $registrypath -Force | Out-Null
	New-ItemProperty -path $registrypath -name $name -value $value -propertype DWORD -force | Out-Null
}}
else {
Write-Host 'cancelled'
}
$decision = $Host.UI.PromptForChoice($title5, $question, $choices, 1)
if ($decision -eq 0) { 
Invoke-Webrequest -uri https://raw.githubusercontent.com/harryeetsource/WindowsScripts/9ddb625d7bcf939175a027930d9195ad1565a628/WuReset2.0.bat -OutFile "${env:temp}\wu.bat" 
Start-Process -Filepath  "${env:temp}\wu.bat"
}
else {
Write-Host 'cancelled'
}
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'

try {
    Repair-WindowsImage -Online -Restorehealth -Startcomponentcleanup -ResetBase
}
catch { 'Issues with provided argument, starting basic windows repair.'
    {1: Repair-WindowsImage -Online -Restorehealth}
     
}
Get-AppXPackage -AllUsers | Foreach-Object {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
Start-Process -FilePath "${env:Windir}\System32\cmd.EXE" -ArgumentList '/c sfc /scannow' -Wait -Verb RunAs
} 
else {
    Write-Host 'cancelled'
}
Write-Host 'Admin updates completed.'
Pause

