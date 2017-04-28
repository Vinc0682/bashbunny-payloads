# WinKeylog
* Author: VincBreaker
* Props: jafahulo for doing some improvements. (Turned out to be a big help)
* Props: illwill, Diggster, IMcPwn, Hak5Darren for providing pre made code I was able to combine.
* Keylogger: https://www.nextofwindows.com/creating-a-simple-keylogger-using-powershell-download
* Version: Version 1.1
* Target: Windows 10 (chances are it also runs older Windows versions)

## Description

Launches a basic PowerShell keylogger which is able to either store the pressed keys to the BB via USB or pull them to
an external backend-server. Both options allow you to kill the keylogger easily by unplugging the BashBunny or by 
specifying an specific session to terminate at the backend. Combined with the cleanup option, this keylogger doesn't 
leave any traces since the script directly runs from the BB.

## Configuration

Settings within payload.txt:

* Keyboard-Layout: The keyboard layout to be used for the keystroke injection. 
The specified language should be installed within the BB/languages folder.

* Exfil-Type: Decide weather the keys should should be saved directly to the BB (via USB) 
(Keylogger will dye once the BB is unplugged) or weather it should upload them to an external
backend website (experimental) which is able to remotely kill the keylogger. Exfiltation via SMB
is work-in-progress.

* Pre-Delay: This option allows you to delay the payload by e.g. 2 Minutes to make it harder
to relate the few pop-ups to the usb stick for the target. (Useful for social engineering)

* Clean-Up: The work no ones want's to do. Deletes the Win + R history to remove all traces.

## Set up (Web)

1. Set up and server running PHP (the payload has been tested with a LEMP-Setup)
2. Paste the backend.php script into any place accessible to the public via your webserver.
3. To test, simply browse to the URI. If everything is ok, you should see an "Bad request" error message
which is an additional layer of disguise against curious sysadmins.
4. Paste the complete URI into the PowerShell script.

## STATUS

| LED                | Status                                       |
| ------------------ | -------------------------------------------- |
| Solid magenta      | Setup and pre-delay                          |
| Single yellow      | Launching keylogger                          |
| Double yellow      | Cleaning up                                  |
| Green solid        | Done                                         |

## TO-DO
* Maybe, we can completely hide the PowerShell window to the target would only see the Win + R box.

* Implement SMB as an exfil method.

* Download or directly execute the payload directly from an specified source (likely the same as the one used exfil)
so the BB doesn't have to enable storage access when WEB or SMB is being used.