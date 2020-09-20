@echo off

::Check for admin privileges
IF EXIST %SYSTEMROOT%\SYSTEM32\WDI\LOGFILES GOTO GOTADMIN
echo Please close this window then right click this .bat file and Run as administrator
echo so the script can copy required files to the system.
pause
exit
:GOTADMIN

::Set variables
SET ScriptVersion=1.0
SET OpenALSoftVersion=1.20.1
SET OpenALSoftInstallationFolder=%APPDATA%\OpenAL
SET OpenALSoftINIPath=%APPDATA%\alsoft.ini
set CurrentDate=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%
set CurrentDate=%CurrentDate: =0%
SET BackupPath=UserFiles\Backup_%CurrentDate%
SET LogFilePath=UserFiles\Log_%CurrentDate%.txt
SET OpenALDLLPathx32=System32\OpenAL32.dll
SET OpenALDLLPathx64=SysWOW64\OpenAL32.dll

::Info
echo.
echo :::::::::::::::::::: UniversAL 3D Audio Manager %ScriptVersion% ::::::::::::::::::::
echo This script will install the required files to enable 3D audio in OpenAL games.
pause
echo.

::Reset working folder. Needed when running as administrator
pushd %~dp0

::Create folder for backup and log
IF NOT EXIST UserFiles (
	mkdir UserFiles
	)

::Install OpenAL system driver
echo Installing OpenAL...
Resources\OpenAL\Installer\oalinst.exe /SILENT >>%LogFilePath%
echo OpenAL has been installed!
echo.

::Install OpenAL Soft
	::Backup
		::Backup existing installation
		IF EXIST %OpenALSoftInstallationFolder% (
			echo OpenAL Soft installation has been found. Copying files to the Backup folder...
			xcopy %OpenALSoftInstallationFolder%\ %BackupPath%\APPDATA\OpenAL\  /s /y >>%LogFilePath%
			echo Backup of OpenAL Soft installation folder has been created!
			)
		::Backup existing configuration
		IF EXIST %OpenALSoftINIPath% (
			copy %OpenALSoftINIPath% %BackupPath%\APPDATA\alsoft.ini >>%LogFilePath%
			echo Backup of OpenAL Soft configuration file has been created!
			)
		::Backup existing system DLLs
		IF EXIST %WINDIR%\%OpenALDLLPathx32% (
			mkdir %BackupPath%\WINDIR\System32
			copy %WINDIR%\%OpenALDLLPathx32% %BackupPath%\WINDIR\%OpenALDLLPathx32% >>%LogFilePath%
			echo Backup of 32 bit OpenAL DLL has been created!
			)
		IF EXIST %WINDIR%\%OpenALDLLPathx64% (
			mkdir %BackupPath%\WINDIR\SysWOW64
			copy %WINDIR%\%OpenALDLLPathx64% %BackupPath%\WINDIR\%OpenALDLLPathx64% >>%LogFilePath%
			echo Backup of 64 bit OpenAL DLL has been created!
			)
	::Install
	echo Installing OpenAL Soft %OpenALSoftVersion%...
		::Installation folder
		IF NOT EXIST %OpenALSoftInstallationFolder% (
			mkdir %OpenALSoftInstallationFolder%
			)
		xcopy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL %OpenALSoftInstallationFolder% /s /y >>%LogFilePath%
		::Configuration
		copy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\alsoft.ini %OpenALSoftINIPath% >>%LogFilePath%
		::32 bit DLL
		copy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\bin\Win64\soft_oal.dll %WINDIR%\%OpenALDLLPathx32% >>%LogFilePath%
		::64 bit DLL
		copy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\bin\Win32\soft_oal.dll %WINDIR%\%OpenALDLLPathx64% >>%LogFilePath%
	echo OpenAL Soft %OpenALSoftVersion% has been installed!
	echo.

::Register dsound.dll
echo Registering dsound.dll...
Resources\DirectSound\RegisterDLL.reg >>%LogFilePath%
echo dsound.dll has been registered!
echo.
::Required for DSOAL on Windows 8+ for games to load dsound.dll from their own folder.

::Complete
echo :::::::::::::::::::: Installation complete! ::::::::::::::::::::
echo.
echo Press any key to configure OpenAL Soft.
echo Recommended if you need to change your Preferred HRTF in the HRTF tab.
echo Otherwise, close this window.
pause
start %OpenALSoftInstallationFolder%\alsoft-config\alsoft-config.exe
exit