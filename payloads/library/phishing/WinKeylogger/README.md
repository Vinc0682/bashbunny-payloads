# WinKeylog
* Author: VincBreaker
* Props: illwill, Diggster, IMcPwn, Hak5Darren for providing pre made code I was able to combine.
* Keylogger: https://www.nextofwindows.com/creating-a-simple-keylogger-using-powershell-download
* Version: Version 1.0
* Target: Windows 10

## Description

Launches a basic PowerShell keylogger which will save all keyprint into a file within the loot folder of your BB.
The script is never copied over to the target and is terminated once the BB is ejected so the logger is at least pretty
 silent.

## Configuration

Settings within payload.txt:

* Keyboard-Layout: The keyboard layout to be used for the keystroke injection. 
The specified language should be installed within the BB/languages folder.

* Pre-Delay: This option allows you to delay the payload by e.g. 2 Minutes to make it harder
to relate the few pop-ups to the usb stick for the target. (Useful for social engineering)

* Clean-Up: The work no ones want's to do. Deletes the Win + R history to remove all traces.

## STATUS

| LED                | Status                                       |
| ------------------ | -------------------------------------------- |
| Solid magenta      | Setup and pre-delay                          |
| Single yellow      | Launching keylogger                          |
| Double yellow      | Cleaning up                                  |
| Green solid        | Done                                         |

## TO-DO
Maybe, we can completly hide the powershell window to the target would only see the Win + R box.

Make the keylogger send the keystrokes to a server so it will no longer depend on the BB being plugged in.