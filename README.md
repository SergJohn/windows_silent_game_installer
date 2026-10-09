# Windows silent game installer

Simple project that does what the title says... run game installer silently.
It works with old games that have a .exe file (the success of the script depends on the installer type - works for more coverage to be done, if necessary).

## Addition of a powershell script (Windows 7 compatible)

Created silent_installer.ps1. A few notes on Windows 7 compatibility decisions:
  
- Uses Start-Process -Wait -PassThru instead of subprocess.run — this is available in PS 2.0 and correctly captures the exit code.
- Uses a for loop with index instead of foreach with $i tracking, keeping it simple and compatible.
- Uses Add-Content for log writing instead of stream objects — PS 2.0 safe.
- Avoids [PSCustomObject], pipelines with -is, #requires, and other PS 3.0+ features.

To run it on Windows, the user may need to allow script execution first:
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Then run with:
```
.\silent_installer.ps1
```
