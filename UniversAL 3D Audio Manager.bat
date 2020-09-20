@echo off

::Set variables
	::General
	SET ScriptVersion=1.1
	SET CurrentDate=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%
	SET CurrentDate=%CurrentDate: =0%
	SET BackupPath=UserFiles\Backup_%CurrentDate%
	SET LogFilePath=UserFiles\Log_%CurrentDate%.txt
	::OpenAL Soft
	SET OpenALSoftVersion=1.20.1
	SET OpenALSoftInstallationFolder=%APPDATA%\OpenAL
	SET OpenALSoftDLLx32Path=%OpenALSoftInstallationFolder%\bin\Win32\soft_oal.dll
	SET OpenALSoftDLLx64Path=%OpenALSoftInstallationFolder%\bin\Win64\soft_oal.dll
	SET OpenALSoftINIPath=%APPDATA%\alsoft.ini
	SET OpenALDLLx32Path=System32\OpenAL32.dll
	SET OpenALDLLx64Path=SysWOW64\OpenAL32.dll
	::DSOAL
	SET DSOALVersion=1.31a
	SET GamePath=%~d1%~p1

::Reset working folder. Needed when running as administrator
pushd %~dp0

::Create folder for backup and log
IF NOT EXIST %BackupPath%\GameExeFolder (
	mkdir %BackupPath%\GameExeFolder
	)

::DSOAL
	::Drag and drop check
	IF DEFINED GamePath (
		::Info
		echo.
		echo :::::::::::::::::::: UniversAL 3D Audio Manager %ScriptVersion% ::::::::::::::::::::
		echo Installing: DSOAL %DSOALVersion%
		echo This will enable 3D audio in the DirectSound3D game whose .exe you dropped onto this .bat script.
		echo.
		::Backup
		echo Creating backup if necessary...
		IF EXIST "%GamePath%\dsound.dll" (
			copy "%GamePath%\dsound.dll" "%BackupPath%\GameExeFolder\dsound.dll" >>%LogFilePath%
			)
		IF EXIST "%GamePath%\dsoal-aldrv.dll" (
			copy "%GamePath%\dsoal-aldrv.dll" "%BackupPath%\GameExeFolder\dsoal-aldrv.dll" >>%LogFilePath%
			)
		IF EXIST "%GamePath%\alsoft.ini" (
			copy "%GamePath%\alsoft.ini" "%BackupPath%\GameExeFolder\alsoft.ini" >>%LogFilePath%
			)
		IF EXIST "%GamePath%\OpenAL" (
			xcopy "%GamePath%\OpenAL\" "%BackupPath%\GameExeFolder\OpenAL\"  /s /y >>%LogFilePath%
			)
		echo Backup of DSOAL has been created!
		::Install
		echo Installing DSOAL into the game folder...
		copy "Resources\DSOAL\%DSOALVersion%\dsound.dll" "%GamePath%\dsound.dll" >>%LogFilePath%
		IF EXIST "%OpenALSoftDLLx32Path%" (
			copy "%OpenALSoftDLLx32Path%" "%GamePath%\dsoal-aldrv.dll" >>%LogFilePath%
			) else (
			copy "Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\bin\Win32\soft_oal.dll" "%GamePath%\dsoal-aldrv.dll" >>%LogFilePath%
			)
		IF EXIST "%OpenALSoftINIPath%" (
			copy "%OpenALSoftINIPath%" "%GamePath%\alsoft.ini" >>%LogFilePath%
			) else (
			copy "Resources\OpenALSoft\Common\APPDATA\alsoft.ini" "%GamePath%\alsoft.ini" >>%LogFilePath%
			)
		IF EXIST "%OpenALSoftInstallationFolder%" (
			xcopy "%OpenALSoftInstallationFolder%\" "%GamePath%\OpenAL\"  /s /y >>%LogFilePath%
		) else (
			xcopy "Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\" "%GamePath%\OpenAL\"  /s /y >>%LogFilePath%
		)
		echo.
		::Complete
		echo :::::::::::::::::::: Installation complete! ::::::::::::::::::::
		echo Your game is now 3D audio-capable. 
		echo Make sure to enable DirectSound3D/EAX/Hardware acceleration options in-game if necessary.
		pause
		exit
		)

::OpenAL Soft
	::Check for admin privileges
	IF EXIST %SYSTEMROOT%\SYSTEM32\WDI\LOGFILES GOTO GOTADMIN
	echo Please close this window then right click this .bat file and Run as administrator
	echo so the script can copy required files to the system.
	pause
	exit
	:GOTADMIN

	::Info
	echo.
	echo :::::::::::::::::::: UniversAL 3D Audio Manager %ScriptVersion% ::::::::::::::::::::
	echo Installing: OpenAL Soft %OpenALSoftVersion%
	echo This will enable 3D audio in OpenAL games.
	pause
	echo.

	::Install OpenAL redistributable
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
			IF EXIST %WINDIR%\%OpenALDLLx32Path% (
				mkdir %BackupPath%\WINDIR\System32
				copy %WINDIR%\%OpenALDLLx32Path% %BackupPath%\WINDIR\%OpenALDLLx32Path% >>%LogFilePath%
				echo Backup of 32 bit OpenAL DLL has been created!
				)
			IF EXIST %WINDIR%\%OpenALDLLx64Path% (
				mkdir %BackupPath%\WINDIR\SysWOW64
				copy %WINDIR%\%OpenALDLLx64Path% %BackupPath%\WINDIR\%OpenALDLLx64Path% >>%LogFilePath%
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
			copy Resources\OpenALSoft\Common\APPDATA\alsoft.ini %OpenALSoftINIPath% >>%LogFilePath%
			::32 bit DLL
			copy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\bin\Win64\soft_oal.dll %WINDIR%\%OpenALDLLx32Path% >>%LogFilePath%
			::64 bit DLL
			copy Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\bin\Win32\soft_oal.dll %WINDIR%\%OpenALDLLx64Path% >>%LogFilePath%
		echo OpenAL Soft %OpenALSoftVersion% has been installed!
		echo.

	::Register dsound.dll
	echo Registering dsound.dll...
	start regedit /s Resources\DirectSound\RegisterDLL.reg >>%LogFilePath%
	::Resources\DirectSound\RegisterDLL.reg >>%LogFilePath%
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