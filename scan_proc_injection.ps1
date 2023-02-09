# Define the process to scan
$processName = "processName.exe"

# Get the process by its name
$process = Get-Process | Where-Object { $_.ProcessName -eq $processName }

# Get the process ID
$pid = $process.Id

# Get the process memory regions
$regions = Get-Process -Id $pid | Select-Object -ExpandProperty VM | Where-Object { $_.State -eq "Commit" }

# Iterate over each memory region
foreach ($region in $regions) {
    # Get the region start and end addresses
    $start = $region.BaseAddress
    $end = [IntPtr]::Add($start, $region.RegionSize)

    # Read the memory region
    $memory = [System.Runtime.InteropServices.Marshal]::Copy($start, [Byte[]]::new($region.RegionSize), 0, $region.RegionSize)

    # Check if the memory region contains a PE header
    $peHeader = [System.IntPtr]::Zero
    try {
        $peHeader = [System.Reflection.Assembly]::Load($memory).GetModules()[0].PEHeader
    } catch { }

    # If the memory region contains a PE header, dump the region to disk
    if ($peHeader -ne [System.IntPtr]::Zero) {
        # Define the output file name
        $outputFile = "$processName-0x$($start.ToString("X")).dll"

        # Write the memory region to disk
        [System.IO.File]::WriteAllBytes($outputFile, $memory)

        Write-Output "Dumped injected code or portable executable to $outputFile"
    }
}
