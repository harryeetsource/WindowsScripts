# Get all processes
$processes = Get-Process

# Loop through each process
foreach ($process in $processes)
{
    # Create a memory dump of the process
    $memory = $process.Name + ".dmp"
    [System.Diagnostics.Process]::Start("procdump", "-accepteula -ma $($process.Id) $memory")
    Start-sleep -seconds 45	
}
