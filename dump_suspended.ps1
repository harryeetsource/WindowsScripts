# Define the process ID and output file
$pid = [int]$args[0]
$outputFile = $args[1]

# Attach to the process
$process = Get-Process -Id $pid
$processHandle = $process.Handle

# Get the memory regions of the process
$memoryRegions = [Diagnostics.ProcessThread]::GetProcessThreads($pid) | 
    Select-Object -ExpandProperty BaseAddress, RegionSize

# Loop through each memory region
foreach ($memoryRegion in $memoryRegions) {
    $baseAddress = $memoryRegion.BaseAddress
    $size = $memoryRegion.RegionSize

    # Allocate memory for the memory region
    $allocatedMemory = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($size)

    # Read the memory region into the allocated memory
    [Diagnostics.ProcessThread]::ReadProcessMemory($processHandle, $baseAddress, $allocatedMemory, $size, [ref]$bytesRead)

    # Write the allocated memory to disk
    [System.IO.File]::WriteAllBytes($outputFile, [System.Runtime.InteropServices.Marshal]::PtrToStructure($allocatedMemory, [System.Array[byte]]))

    # Free the allocated memory
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($allocatedMemory)
}

# Close the process handle
[Diagnostics.ProcessThread]::CloseHandle($processHandle)
