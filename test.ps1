$title    = 'Starting Administrative Windows Repairs'
$question = 'Are you sure you want to proceed?'
$choices  = '&Yes', '&No'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0) {
    Write-Host 'confirmed'
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

Repair-WindowsImage -Online -Restorehealth -Startcomponentcleanup -ResetBase
Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register -ErrorAction SilentlyContinue "$($_.InstallLocation)\AppXManifest.xml"}
sfc.exe /scannow
} 
else {
    Write-Host 'cancelled'
}