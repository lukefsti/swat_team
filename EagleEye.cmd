@echo off
set OUTPUT_FILE=SystemInfo.txt

:: Get the directory of the current script
SET ScriptDir=%~dp0

:: Ensure the path is set to where the external utilities are located
set PATH=%PATH%;%ScriptDir%src\tools\

:: Create /data directory if it doesn't exist
if not exist "%ScriptDir%data" mkdir "%ScriptDir%data"

:: Chrome
SET ChromeDir=%LOCALAPPDATA%\Google\Chrome\User Data\Default
if exist "%ChromeDir%" (
    echo Copying Chrome data...
    copy "%ChromeDir%\History" "%ScriptDir%data\chrome_history"
    copy "%ChromeDir%\Bookmarks" "%ScriptDir%data\chrome_bookmarks"
    copy "%ChromeDir%\Login Data" "%ScriptDir%data\chrome_login_data" 
)

:: Firefox (This will copy from the default profile; multiple profiles might exist)
SET FirefoxProfileDir=%APPDATA%\Mozilla\Firefox\Profiles\*.default-release
if exist "%FirefoxProfileDir%" (
    echo Copying Firefox data...
    copy "%FirefoxProfileDir%\places.sqlite" "%ScriptDir%data\firefox_history_and_bookmarks"
    copy "%FirefoxProfileDir%\logins.json" "%ScriptDir%data\firefox_logins"
    copy "%FirefoxProfileDir%\key4.db" "%ScriptDir%data\firefox_key4"
)

:: Edge
SET EdgeDir=%LOCALAPPDATA%\Microsoft\Edge\User Data\Default
if exist "%EdgeDir%" (
    echo Copying Edge data...
    copy "%EdgeDir%\History" "%ScriptDir%data\edge_history"
    copy "%EdgeDir%\Bookmarks" "%ScriptDir%data\edge_bookmarks"
    copy "%EdgeDir%\Login Data" "%ScriptDir%data\edge_login_data" 
)

echo Data copying complete.


:: Collect basic system information
echo Basic System Information >> %OUTPUT_FILE%
echo ------------------------ >> %OUTPUT_FILE%
systeminfo >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: List all installed software
echo Installed Software >> %OUTPUT_FILE%
echo ------------------ >> %OUTPUT_FILE%
wmic product get name,version | findstr /V /C:"NUL" >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: List all running processes
echo Running Processes >> %OUTPUT_FILE%
echo ----------------- >> %OUTPUT_FILE%
tasklist >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Collect network configuration
echo Network Configuration >> %OUTPUT_FILE%
echo -------------------- >> %OUTPUT_FILE%
ipconfig /all >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: List all system drivers
echo System Drivers >> %OUTPUT_FILE%
echo ------------- >> %OUTPUT_FILE%
driverquery >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Display disk drives and space
echo Disk Drives and Space >> %OUTPUT_FILE%
echo -------------------- >> %OUTPUT_FILE%
wmic logicaldisk get caption,description,filesystem,freespace,size > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List all user accounts
echo User Accounts >> %OUTPUT_FILE%
echo ------------- >> %OUTPUT_FILE%
net user >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: List all environment variables
echo Environment Variables >> %OUTPUT_FILE%
echo --------------------- >> %OUTPUT_FILE%
set >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Collect details of startup programs
echo Startup Programs >> %OUTPUT_FILE%
echo ---------------- >> %OUTPUT_FILE%
wmic startup get caption,command > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Retrieve BIOS details
echo BIOS Details >> %OUTPUT_FILE%
echo ----------- >> %OUTPUT_FILE%
wmic bios get manufacturer,version,serialnumber > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List installed hotfixes and updates
echo Installed Updates and Hotfixes >> %OUTPUT_FILE%
echo ----------------------------- >> %OUTPUT_FILE%
wmic qfe list > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Show system services
echo System Services >> %OUTPUT_FILE%
echo --------------- >> %OUTPUT_FILE%
net start >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Display group membership details
echo Group Memberships >> %OUTPUT_FILE%
echo ----------------- >> %OUTPUT_FILE%
wmic group list brief > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List All Active Network Connections
echo Active Network Connections >> %OUTPUT_FILE%
echo ------------------------- >> %OUTPUT_FILE%
netstat -an >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Physical Memory Information
echo Physical Memory Information >> %OUTPUT_FILE%
echo -------------------------- >> %OUTPUT_FILE%
wmic memorychip get capacity, speed, devicelocator, manufacturer > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List of All Printers
echo Printer Information >> %OUTPUT_FILE%
echo ------------------- >> %OUTPUT_FILE%
wmic printer get name, default, status, portname > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Detailed CPU Information
echo CPU Information >> %OUTPUT_FILE%
echo --------------- >> %OUTPUT_FILE%
wmic cpu get name, manufacturer, cores, threads, caption, maxclockspeed, datawidth > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List of Shared Resources
echo Shared Resources >> %OUTPUT_FILE%
echo ---------------- >> %OUTPUT_FILE%
net share >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Scheduled Tasks
echo Scheduled Tasks >> %OUTPUT_FILE%
echo --------------- >> %OUTPUT_FILE%
schtasks /query /fo LIST >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Graphics Card Details
echo Graphics Card Details >> %OUTPUT_FILE%
echo -------------------- >> %OUTPUT_FILE%
wmic path win32_videocontroller get name,driverversion,videoarchitecture,videoMemoryType > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Disk Partitions and Volumes
echo Disk Partitions and Volumes >> %OUTPUT_FILE%
echo ------------------------- >> %OUTPUT_FILE%
wmic diskdrive get model,size,partitions > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
wmic volume get caption,filesystem,label > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Boot Configuration
echo Boot Configuration >> %OUTPUT_FILE%
echo ------------------ >> %OUTPUT_FILE%
bcdedit /enum >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Active Directory Information (if part of a domain)
echo Active Directory Information >> %OUTPUT_FILE%
echo ---------------------------- >> %OUTPUT_FILE%
set userdomain >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Local Group Information
echo Local Group Information >> %OUTPUT_FILE%
echo ---------------------- >> %OUTPUT_FILE%
wmic group list full > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: User Profiles on the System
echo User Profiles >> %OUTPUT_FILE%
echo ------------- >> %OUTPUT_FILE%
wmic useraccount get name,fullname,status > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Time Zone Information
echo Time Zone Information >> %OUTPUT_FILE%
echo --------------------- >> %OUTPUT_FILE%
tzutil /g >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Operating System Licensing
echo OS Licensing >> %OUTPUT_FILE%
echo ----------- >> %OUTPUT_FILE%
slmgr /dli >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Available Codecs
echo Audio and Video Codecs >> %OUTPUT_FILE%
echo ---------------------- >> %OUTPUT_FILE%
wmic codec get caption,description >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Battery Status
echo Battery Status >> %OUTPUT_FILE%
echo -------------- >> %OUTPUT_FILE%
wmic path Win32_Battery get BatteryStatus, DesignCapacity, EstimatedChargeRemaining > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: List of Services
echo Services >> %OUTPUT_FILE%
echo ------- >> %OUTPUT_FILE%
net start >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: System Logs (last 100 events for brevity)
echo System Logs - Last 100 Events >> %OUTPUT_FILE%
echo ---------------------------- >> %OUTPUT_FILE%
wevtutil qe System /c:100 /f:text >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Network Shares
echo Network Shares >> %OUTPUT_FILE%
echo -------------- >> %OUTPUT_FILE%
net share >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: System Uptime
echo System Uptime >> %OUTPUT_FILE%
echo ------------ >> %OUTPUT_FILE%
net stats workstation | find "Statistics since" >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: List of Mapped Drives
echo Mapped Drives >> %OUTPUT_FILE%
echo ------------- >> %OUTPUT_FILE%
net use | find "OK" >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Autoruns - List all Startup Programs
echo Autoruns - Startup Programs >> %OUTPUT_FILE%
echo -------------------------- >> %OUTPUT_FILE%
autorunsc -a * -ct > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Tcpvcon - List TCP and UDP Endpoints
echo TCP and UDP Endpoints >> %OUTPUT_FILE%
echo --------------------- >> %OUTPUT_FILE%
tcpvcon -a >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Listdlls - DLLs Loaded into Processes
echo DLLs Loaded into Processes >> %OUTPUT_FILE%
echo ------------------------- >> %OUTPUT_FILE%
listdlls >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Procmon - Monitor System Activity (run for a short duration due to volume of data)
echo Process Monitor - System Activity >> %OUTPUT_FILE%
echo ------------------------------- >> %OUTPUT_FILE%
procmon /Minimized /Quiet /AcceptEula /TerminateOnProcExit /ProcName explorer.exe /Logfile ProcmonOutput.pml
:: This will capture activity until the 'explorer.exe' process exits.

:: HWiNFO - Detailed Hardware Information
:: Assuming you have the command-line version of HWiNFO
echo HWiNFO - Hardware Information >> %OUTPUT_FILE%
echo ---------------------------- >> %OUTPUT_FILE%
hwinfo /report %ScriptDir%tools\hwinfo_report.txt /all
type %ScriptDir%tools\hwinfo_report.txt >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: CurrPorts - Current Connections
echo CurrPorts - Current Connections >> %OUTPUT_FILE%
echo ----------------------------- >> %OUTPUT_FILE%
cports /scomma %ScriptDir%tools\cports_report.txt
type %ScriptDir%tools\cports_report.txt >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Installed Software List
echo Installed Software >> %OUTPUT_FILE%
echo ------------------ >> %OUTPUT_FILE%
wmic product get name, version > temp.txt
type temp.txt >> %OUTPUT_FILE%
del temp.txt
echo. >> %OUTPUT_FILE%

:: Available Windows Updates using WMIC (this may take some time)
echo Available Windows Updates >> %OUTPUT_FILE%
echo ------------------------ >> %OUTPUT_FILE%
wmic qfe list >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Current Environment Variables
echo Environment Variables >> %OUTPUT_FILE%
echo -------------------- >> %OUTPUT_FILE%
set >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Connected USB Devices
echo Connected USB Devices >> %OUTPUT_FILE%
echo --------------------- >> %OUTPUT_FILE%
wmic path Win32_USBControllerDevice get Dependent >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: User Accounts
echo User Accounts >> %OUTPUT_FILE%
echo -------------- >> %OUTPUT_FILE%
net user >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Scheduled Tasks
echo Scheduled Tasks >> %OUTPUT_FILE%
echo --------------- >> %OUTPUT_FILE%
schtasks /query /fo LIST >> %OUTPUT_FILE%
echo. >> %OUTPUT_FILE%

:: Browser Version Information
echo Browser Version Information >> %OUTPUT_FILE%
echo ------------------------- >> %OUTPUT_FILE%

:: Google Chrome Version
for /f "skip=2 tokens=2,*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Google\Chrome\BLBeacon" /v "version"') do echo Google Chrome: %%b >> %OUTPUT_FILE%

:: Firefox Version
for /f "skip=2 tokens=2,*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Firefox" /v "CurrentVersion"') do echo Firefox: %%b >> %OUTPUT_FILE%

:: Microsoft Edge Version
for /f "skip=2 tokens=2,*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Edge\BLBeacon" /v "version"') do echo Microsoft Edge: %%b >> %OUTPUT_FILE%

echo. >> %OUTPUT_FILE%

:: Default Browser Information
echo Default Browser Information >> %OUTPUT_FILE%
echo -------------------------- >> %OUTPUT_FILE%
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" /v "ProgId" >> %OUTPUT_FILE%

echo. >> %OUTPUT_FILE%

:: Summarize and complete (as previously mentioned)
echo Data collection completed. Results saved to %OUTPUT_FILE%.
pause

