$processName = "processName" # replace with actual process name

$process = Get-Process -Name $processName -ErrorAction SilentlyContinue

if ($process -eq $null) {
    Write-Output "$processName not found"
    break
}

$processId = $process.Id

$module = Get-WmiObject -Query "SELECT * FROM Win32_Module WHERE ProcessId = $processId AND BaseAddress = '0x0'" -ErrorAction SilentlyContinue

if ($module -eq $null) {
    Write-Output "Hooks not found for $processName"
    break
}

foreach ($mod in $module) {
    $result = $mod.Unload()
    if ($result.ReturnValue -eq 0) {
        Write-Output "Hook removed from $processName"
    } else {
        Write-Output "Failed to remove hook from $processName with error code $($result.ReturnValue)"
    }
}

Start-Process -FilePath $process.Path
