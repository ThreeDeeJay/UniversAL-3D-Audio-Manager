@echo off

::Reset working folder. Needed when running as administrator.
pushd %~dp0

::Variables
	::OpenAL Soft
SET OpenALSoftVersion=1.20.1
SET OpenALSoftBranch=DirectSound
	IF "%OpenALSoftBranch%"=="WASAPI" (
		SET OpenALSoftVersionBranch=%OpenALSoftVersion%-%OpenALSoftBranch%
		) else (
		SET OpenALSoftVersionBranch=%OpenALSoftVersion%
		)
	SET OpenALSoftSetupFolder=Resources\OpenALSoft\%OpenALSoftVersionBranch%
	SET OpenALSoftInstallationFolder=%APPDATA%\OpenAL
	SET OpenALSoftHRTFFolder=%OpenALSoftInstallationFolder%\HRTF
	SET OpenALSoftPresetsFolder=%OpenALSoftInstallationFolder%\presets
	SET OpenALSoftDLLx32Path=%OpenALSoftInstallationFolder%\bin\Win32\soft_oal.dll
	SET OpenALSoftDLLx64Path=%OpenALSoftInstallationFolder%\bin\Win64\soft_oal.dll
	SET OpenALSoftINIPath=%APPDATA%\alsoft.ini
	SET OpenALDLLx32Path=SysWOW64\OpenAL32.dll
	SET OpenALDLLx64Path=System32\OpenAL32.dll
	::DSOAL
SET DSOALVersion=1.31a
SET OpenALSoftDSOALVersion=1.19.1
SET OpenALSoftDSOALBranch=DirectSound
	IF "%OpenALSoftDSOALBranch%"=="WASAPI" (
		SET OpenALSoftDSOALVersionBranch=%OpenALSoftDSOALVersion%-%OpenALSoftDSOALBranch%
		) else (
		SET OpenALSoftDSOALVersionBranch=%OpenALSoftDSOALVersion%
		)
	SET OpenALSoftDSOALSetupFolder=Resources\OpenALSoft\%OpenALSoftDSOALVersionBranch%
	SET DSOALSetupFolder=Resources\DSOAL\%DSOALVersion%
	SET GameExeFullPath=%~1
	For %%A in ("%GameExeFullPath%") do (
	    SET "GameExeFolderPath=%%~dpA"
	    SET "GameExeFilename=%%~nxA"
	    )
	::General
	SET ScriptVersion=1.7
	SET CurrentDate=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%
	SET CurrentDate=%CurrentDate: =0%
	SET UserFilesFolder=UserFiles
	SET BackupPath=%UserFilesFolder%\Backup\Backup_%CurrentDate%
	SET LogFilePath=%UserFilesFolder%\Log.txt
	::External
	SET HeSuViPath="C:\Program Files\EqualizerAPO\config\HeSuVi\HeSuVi.exe"
	SET ChatURL=https://kutt.it/U3DAMChat

::Title bar
title UniversAL 3D Audio Manager v%ScriptVersion%

::Create folder for log and backup
IF NOT EXIST %BackupPath% (
	mkdir %BackupPath%
	)

::Log header and timestamp
echo.>>%LogFilePath%
echo.>>%LogFilePath%
echo.>>%LogFilePath%
echo.>>%LogFilePath%
echo.>>%LogFilePath%
echo -------------------------------------------------- %CurrentDate% -------------------------------------------------->>%LogFilePath%
echo.>>%LogFilePath%

::DSOAL

	::Check for .bat file drag and drop
	IF DEFINED GameExeFolderPath (

	::Install DSOAL
	:InstallDSOAL

		::Check if selected DSOAL version and branch exists
		IF NOT EXIST %DSOALSetupFolder% (
			call :PrintAndLog "[91mThe folder for the selected DSOAL version and branch does not exist.[0m"
			call :PrintAndLog "[91mPlease make sure that the variable DSOALVersion is set to the right value.[0m"
			pause
			exit
		)

		::Check if selected OpenAL Soft version and branch exists
		IF NOT EXIST %OpenALSoftDSOALSetupFolder% (
			call :PrintAndLog "[91mThe folder for the selected OpenAL Soft DSOAL version and branch does not exist.[0m"
			call :PrintAndLog "[91mPlease make sure that the variables OpenALSoftDSOALVersion and OpenALSoftDSOALBranch are set to the right values.[0m"
			pause
			exit
		)

		::Info
		call :SplashInfo
		call :PrintAndLog "- DSOAL version: [1m%DSOALVersion%[0m"
		call :PrintAndLog "- OpenAL Soft version: [1m%OpenALSoftDSOALVersionBranch%[0m"
		echo.
		call :PrintAndLog "- Game folder: [1m%GameExeFolderPath%[0m"
		call :PrintAndLog "- Game executable: [1m%GameExeFilename%[0m"
		echo.
		call :PrintAndLog "This script will:"
		call :PrintAndLog "- Backup and/or (re)install DSOAL using existing OpenAL Soft global settings."
		call :PrintAndLog "- Set default playback device's format to 24 bit, 48000hz."
		IF NOT "%OpenALSoftDSOALBranch%"=="WASAPI" (
			call :PrintAndLog "- Disable:"
			call :PrintAndLog "    - Exclusive Mode"
			call :PrintAndLog "    - Windows spatial sound"
			call :PrintAndLog "    - HeSuVi"
			) else (
			call :PrintAndLog "- Enable:"
			call :PrintAndLog "    - Exclusive Mode"
			)
		call :PrintAndLog "- Fix DirectSound references in the registry."
		echo.
		pause

		::Info
		title UniversAL 3D Audio Manager v%ScriptVersion% - Installing: DSOAL v%DSOALVersion% - OpenAL Soft v%OpenALSoftDSOALVersionBranch%
		call :SplashInfoDSOALSmall

		::Check if DSOAL was properly installed
			IF EXIST "%GameExeFolderPath%OpenAL\HRTF" (
				IF EXIST "%GameExeFolderPath%OpenAL\presets" (
					IF EXIST "%GameExeFolderPath%dsound.dll" (
						IF EXIST "%GameExeFolderPath%dsoal-aldrv.dll" (
							IF EXIST "%GameExeFolderPath%alsoft.ini" (
								call :PrintAndLog "Backing up existing DSOAL installation..."
								) else (
								goto InstallDSOALFiles
								)
								)
								)
								)
								)

		::Backup DSOAL
		:BackupDSOALFiles
			IF NOT EXIST %BackupPath%\GameExeFolder (
				mkdir %BackupPath%\GameExeFolder
				)
			::Backup dsound.dll
			IF EXIST "%GameExeFolderPath%dsound.dll" (
				copy "%GameExeFolderPath%dsound.dll" "%BackupPath%\GameExeFolder\dsound.dll" >>%LogFilePath%
				del "%GameExeFolderPath%dsound.dll" >>%LogFilePath%
				)
			::Backup dsoal-aldrv.dll
			IF EXIST "%GameExeFolderPath%dsoal-aldrv.dll" (
				copy "%GameExeFolderPath%dsoal-aldrv.dll" "%BackupPath%\GameExeFolder\dsoal-aldrv.dll" >>%LogFilePath%
				del "%GameExeFolderPath%dsoal-aldrv.dll" >>%LogFilePath%
				)
			::Backup alsoft.ini
			IF EXIST "%GameExeFolderPath%alsoft.ini" (
				copy "%GameExeFolderPath%alsoft.ini" "%BackupPath%\GameExeFolder\alsoft.ini" >>%LogFilePath%
				del "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
				)
			::Backup OpenAL folder
			IF EXIST "%GameExeFolderPath%OpenAL" (
				xcopy "%GameExeFolderPath%OpenAL" "%BackupPath%\GameExeFolder\OpenAL\"  /s /y >>%LogFilePath%
				rmdir /s /q "%GameExeFolderPath%OpenAL\"
				)
			::Check if DSOAL was backed up successfully
			IF EXIST "%BackupPath%\GameExeFolder\dsound.dll" (
				IF EXIST "%BackupPath%\GameExeFolder\dsoal-aldrv.dll" (
					IF EXIST "%BackupPath%\GameExeFolder\alsoft.ini" (
						IF EXIST "%BackupPath%\GameExeFolder\OpenAL\" (
							call :PrintAndLog "[92mDSOAL has been successfully backed up![0m"
							echo.
							) else (
							call :PrintAndLog "[91mDSOAL backup has failed![0m"
							goto DSOALFailure
							)
						)
					)
				)
		
		::Install DSOAL
		:InstallDSOALFiles
			call :PrintAndLog "Installing DSOAL [1mv%DSOALVersion%[0m into the folder containing [1m%GameExeFilename%[0m..."
				::Install HRTF folder
				IF EXIST "%OpenALSoftHRTFFolder%" (
					xcopy "%OpenALSoftHRTFFolder%" "%GameExeFolderPath%OpenAL\HRTF\"  /s /y >>%LogFilePath%
				) else (
					xcopy "Resources\Common\OpenAL\HRTF" "%GameExeFolderPath%OpenAL\HRTF\"  /s /y >>%LogFilePath%
				)
				::Install presets folder
				IF EXIST "%OpenALSoftPresetsFolder%" (
					xcopy "%OpenALSoftPresetsFolder%" "%GameExeFolderPath%OpenAL\presets\"  /s /y >>%LogFilePath%
				) else (
					xcopy "Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\presets" "%GameExeFolderPath%OpenAL\presets\"  /s /y >>%LogFilePath%
				)
				::Install dsound.dll
				copy "Resources\DSOAL\%DSOALVersion%\GameExeFolder\dsound.dll" "%GameExeFolderPath%dsound.dll" >>%LogFilePath%
				::Install dsoal-aldrv.dll
				copy "Resources\OpenALSoft\%OpenALSoftDSOALVersionBranch%\APPDATA\OpenAL\bin\Win32\soft_oal.dll" "%GameExeFolderPath%dsoal-aldrv.dll" >>%LogFilePath%
				::Install alsoft.ini
				IF EXIST "%OpenALSoftINIPath%" (
					copy "%OpenALSoftINIPath%" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					) else (
					copy "Resources\Common\alsoft.ini" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					)
				IF "%OpenALSoftDSOALBranch%"=="WASAPI" (
					::Period size
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General period_size 160 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Periods
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General periods 1 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Sample type
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General sample-type int16 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Drivers
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General drivers "wasapi," > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
				) else (
					::Period size
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General period_size 1024 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Periods
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General periods 3 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Sample type
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General sample-type float32 > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
					::Drivers
					Resources\Tools\initool\initool.exe s "%GameExeFolderPath%alsoft.ini" General drivers "-dsound," > "%GameExeFolderPath%alsoft.ini.temp"
					move /y "%GameExeFolderPath%alsoft.ini.temp" "%GameExeFolderPath%alsoft.ini" >>%LogFilePath%
				)
			::Check if DSOAL was installed successfully
			IF EXIST "%GameExeFolderPath%OpenAL\HRTF" (
				IF EXIST "%GameExeFolderPath%OpenAL\presets" (
					IF EXIST "%GameExeFolderPath%dsound.dll" (
						IF EXIST "%GameExeFolderPath%dsoal-aldrv.dll" (
							IF EXIST "%GameExeFolderPath%alsoft.ini" (
								call :PrintAndLog "[92mDSOAL v%DSOALVersion% has been successfully installed![0m"
								) else (
								goto DSOALFailure
								)
								) else (
								goto DSOALFailure
								)
								) else (
								goto DSOALFailure
								)
								) else (
								goto DSOALFailure
								)
								) else (
								goto DSOALFailure
								)
								echo.

		call :RegisterDSound
		call :AutoConfigGeneral
		call :AutoConfigDSOAL

		::Complete
		:DSOALFinish
		call :PrintAndLog ":::::::::::::::::::: [92mDSOAL v%DSOALVersion% has been installed successfully![0m ::::::::::::::::::::"
		call :Notes
		call :PrintAndLog "[93m- Enable DirectSound3D/EAX/Hardware acceleration if the game has any of those audio options.[0m"
		echo.
		pause
		exit
		)

	::Check for admin privileges
	IF EXIST %SYSTEMROOT%\SYSTEM32\WDI\LOGFILES GOTO GOTADMIN
		call :SplashInfo
		::Check if OpenAL Soft has been installed
		IF EXIST "%OpenALSoftInstallationFolder%" (
			IF EXIST "%OpenALSoftHRTFFolder%" (
				IF EXIST "%OpenALSoftINIPath%" (
					IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
						IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
								call :PrintAndLog "[92mOpenAL Soft installation found! You can proceed to install DSOAL.[0m"
							) else (
								::call :PrintAndLog "OpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL."
								call :PrintAndLog "[93mOpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL.[0m"
							)
							) else (
								::call :PrintAndLog "OpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL."
								call :PrintAndLog "[93mOpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL.[0m"
							)
							) else (
								::call :PrintAndLog "OpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL."
								call :PrintAndLog "[93mOpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL.[0m"
							)
							) else (
								::call :PrintAndLog "OpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL."
								call :PrintAndLog "[93mOpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL.[0m"
							)
							) else (
								::call :PrintAndLog "OpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL."
								call :PrintAndLog "[93mOpenAL Soft installation was not found or not properly installed! Please (re)install it before installing DSOAL.[0m"
							)
							echo.

		::Info
		call :PrintAndLog "To (re)install OpenAL Soft, close this window and right click this .bat file then run as administrator."
		call :PrintAndLog "To (re)install DSOAL, drag and drop the game's .exe into this window to get its path then press Enter."
		::Window exe drag and drop
			::Declare variable with placeholder value
			set GameExeFullPath=Null
			::Check for window drag and drop
			set /p GameExeFullPath=
			::Remove quotes from path
			set GameExeFullPath=%GameExeFullPath:"=%
			::Extract folder path and filename and save to separate variables
			For %%A in ("%GameExeFullPath%") do (
			    SET "GameExeFolderPath=%%~dpA"
			    SET "GameExeFilename=%%~nxA"
			    )
			::Quit script if there was no user input
			IF "%GameExeFullPath%"=="Null" (
				exit
				)
		::Proceed to install DSOAL
		call :InstallDSOAL
	:GOTADMIN

::OpenAL Soft

	::Info
	cls
	call :SplashInfo
	call :PrintAndLog "- OpenAL Soft version: [1mv%OpenALSoftVersionBranch%[0m"
	echo.
	call :PrintAndLog "This script will:"
	call :PrintAndLog "- Install OpenAL redistributable."
	call :PrintAndLog "- Backup and/or (re)install OpenAL Soft."
	call :PrintAndLog "- Update OpenAL DLLs in the Windows folder."
	call :PrintAndLog "- Set default playback device's format to 24 bit, 48000hz."
	IF NOT "%OpenALSoftBranch%"=="WASAPI" (
		call :PrintAndLog "- Disable:"
		call :PrintAndLog "    - Exclusive Mode"
		call :PrintAndLog "    - Windows spatial sound"
		call :PrintAndLog "    - HeSuVi"
		) else (
		call :PrintAndLog "- Enable:"
		call :PrintAndLog "    - Exclusive Mode"
		)
	echo.
	pause

	::Check if selected OpenAL Soft version and branch exists
		IF NOT EXIST %OpenALSoftSetupFolder% (
			call :PrintAndLog "The folder for the selected OpenAL Soft version and branch does not exist."
			call :PrintAndLog "Please make sure that the variables OpenALSoftVersion and OpenALSoftBranch are set to the right values."
			pause
			exit
		)

	::Info
	title UniversAL 3D Audio Manager v%ScriptVersion% - Installing: OpenAL Soft v%OpenALSoftVersionBranch%
	call :SplashInfoOpenALSoftSmall

	::Install OpenAL
	call :PrintAndLog "Installing OpenAL..."
	Resources\OpenAL\Installer\oalinst.exe /SILENT >>%LogFilePath%
	IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
		IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
			call :PrintAndLog "[92mOpenAL has been successfully installed![0m"
			) else (
			call :PrintAndLog "[91mOpenAL installation has failed![0m"
			goto OpenALSoftFailure
			)
		) else (
		call :PrintAndLog "[91mOpenAL installation has failed![0m"
		goto OpenALSoftFailure
		)
	echo.
	::Required by OpenAL Soft
	::Source: https://openal.org/downloads/

	::Backup OpenAL Soft
	call :PrintAndLog "Backing up existing OpenAL Soft..."
		::Backup HRTF folder
		IF EXIST "%OpenALSoftHRTFFolder%" (
			xcopy "%OpenALSoftHRTFFolder%" "%BackupPath%\APPDATA\OpenAL\HRTF\"  /s /y >>%LogFilePath%
			rmdir /s /q "%OpenALSoftHRTFFolder%" >>%LogFilePath%
		)
		::Backup OpenAL folder
		IF EXIST "%OpenALSoftInstallationFolder%" (
			xcopy "%OpenALSoftInstallationFolder%" "%BackupPath%\APPDATA\OpenAL\"  /s /y >>%LogFilePath%
			rmdir /s /q "%OpenALSoftInstallationFolder%" >>%LogFilePath%
			)
		::Backup alsoft.ini
		IF EXIST "%OpenALSoftINIPath%" (
			copy "%OpenALSoftINIPath%" "%BackupPath%\APPDATA\alsoft.ini" >>%LogFilePath%
			del "%OpenALSoftINIPath%" >>%LogFilePath%
			)
		::Backup OpenAL32.dll (32-bit)
		IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
			mkdir "%BackupPath%\WINDIR\SysWOW64" >>%LogFilePath%
			copy "%WINDIR%\%OpenALDLLx32Path%" "%BackupPath%\WINDIR\%OpenALDLLx32Path%" >>%LogFilePath%
			del "%WINDIR%\%OpenALDLLx32Path%" >>%LogFilePath%
			)
		::Backup OpenAL32.dll (64-bit)
		IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
			mkdir "%BackupPath%\WINDIR\System32" >>%LogFilePath%
			copy "%WINDIR%\%OpenALDLLx64Path%" "%BackupPath%\WINDIR\%OpenALDLLx64Path%" >>%LogFilePath%
			del "%WINDIR%\%OpenALDLLx64Path%" >>%LogFilePath%
			)
	::Verify OpenAL Soft backup
	IF EXIST "%BackupPath%" (
		call :PrintAndLog "[92mOpenAL Soft has been successfully backed up![0m"
		) else (
			call :PrintAndLog "[91mOpenAL Soft backup has failed![0m"
			goto OpenALSoftFailure
		)
	echo.

	::Install OpenAL Soft
	call :PrintAndLog "Installing OpenAL Soft [1mv%OpenALSoftVersion%[0m..."
		::Install HRTF folder
		xcopy "Resources\Common\OpenAL\HRTF" "%OpenALSoftHRTFFolder%\" /s /y >>%LogFilePath%
		::Install alsoft.ini
		copy "Resources\Common\alsoft.ini" "%OpenALSoftINIPath%" >>%LogFilePath%
		IF "%OpenALSoftBranch%"=="WASAPI" (
			::Period size
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General period_size 160 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Periods
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General periods 1 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Sample type
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General sample-type int16 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Drivers
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General drivers "wasapi," > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
		) else (
			::Period size
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General period_size 1024 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Periods
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General periods 3 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Sample type
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General sample-type float32 > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			::Drivers
			Resources\Tools\initool\initool.exe s "%OpenALSoftINIPath%" General drivers "-dsound," > "%OpenALSoftINIPath%.temp"
			move /y "%OpenALSoftINIPath%.temp" "%OpenALSoftINIPath%" >>%LogFilePath%
			)
		::Install OpenAL folder
		xcopy "Resources\OpenALSoft\%OpenALSoftVersionBranch%\APPDATA\OpenAL" "%APPDATA%\OpenAL\" /s /y >>%LogFilePath%
		::Install OpenAL32.dll (32-bit)
		copy "Resources\OpenALSoft\%OpenALSoftVersionBranch%\APPDATA\OpenAL\bin\Win32\soft_oal.dll" "%WINDIR%\%OpenALDLLx32Path%" >>%LogFilePath%
		::Install OpenAL32.dll (64-bit)
		copy "Resources\OpenALSoft\%OpenALSoftVersionBranch%\APPDATA\OpenAL\bin\Win64\soft_oal.dll" "%WINDIR%\%OpenALDLLx64Path%" >>%LogFilePath%
		::Verify OpenAL Soft installation
		IF EXIST "%OpenALSoftInstallationFolder%" (
			IF EXIST "%OpenALSoftHRTFFolder%" (
				IF EXIST "%OpenALSoftINIPath%" (
					IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
						IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
							call :PrintAndLog "[92mOpenAL Soft v%OpenALSoftVersion% has been successfully installed![0m"
							) else (
							call :PrintAndLog "[91mOpenAL Soft v%OpenALSoftVersion% installation has failed![0m"
							goto OpenALSoftFailure
							)
							) else (
							call :PrintAndLog "[91mOpenAL Soft v%OpenALSoftVersion% installation has failed![0m"
							goto OpenALSoftFailure
							)
							) else (
							call :PrintAndLog "[91mOpenAL Soft v%OpenALSoftVersion% installation has failed![0m"
							goto OpenALSoftFailure
							)
							) else (
							call :PrintAndLog "[91mOpenAL Soft v%OpenALSoftVersion% installation has failed![0m"
							goto OpenALSoftFailure
							)
							) else (
							call :PrintAndLog "[91mOpenAL Soft v%OpenALSoftVersion% installation has failed![0m"
							goto OpenALSoftFailure
							)
							echo. 

call :AutoConfigGeneral
call :AutoConfigOpenALSoft
call :CleanupLog

::Complete
call :PrintAndLog ":::::::::::::::::::: [92mOpenAL Soft v%OpenALSoftVersion% has been installed successfully![0m ::::::::::::::::::::"
call :Notes
call :PrintAndLog "Press any key to run the configuration tool in case you need to set your Preferred HRTF in the HRTF tab."
call :PrintAndLog "Otherwise, close this window."
echo.
pause
start %OpenALSoftInstallationFolder%\alsoft-config\alsoft-config.exe
exit





::-------------------------------------------------- FUNCTIONS --------------------------------------------------


:Notes
call :PrintAndLog "Notes:"
call :PrintAndLog "[93m- Log is located in %LogFilePath%[0m"
call :PrintAndLog "[93m- Backup is located in %BackupPath%[0m"
call :PrintAndLog "[93m- Disable any other audio effects, except for headphones equalization if needed.[0m"
EXIT /B 0


:SplashInfoSmall
cls
call :PrintAndLog "[90m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[0m"
call :PrintAndLog "[90m::::::::::::::::::::::::::[0m[1m UniversAL 3D Audio Manager v%ScriptVersion% [0m[90m::::::::::::::::::::::::::[0m"
EXIT /B 0

:SplashInfo
call :SplashInfoSmall
	call :PrintAndLog "[90m::::::::::::::::[0m [90mBy 3DJ - github.com/ThreeDeeJay / Discord: 3DJ#5426[0m [90m::::::::::::::::[0m"
	call :PrintAndLog "[90m:::::[0m [90mScript that automates enabling 3D audio in OpenAL and DirectSound3D games[0m [90m:::::[0m"
	call :PrintAndLog "[90m:::::::::::::::::::::::[0m [93mH E A D P H O N E S   R E Q U I R E D[0m [90m:::::::::::::::::::::::[0m"
	call :PrintAndLog "[90m:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::[0m"
	echo.
EXIT /B 0

:SplashInfoDSOALSmall
cls
call :PrintAndLog "[90m:::::::::::::::::::::::::::::::::::::::[0m[44m DSOAL [0m[90m:::::::::::::::::::::::::::::::::::::::[0m"
echo.
EXIT /B 0

:SplashInfoOpenALSoftSmall
cls
call :PrintAndLog "[90m::::::::::::::::::::::::::::::::::::[0m[42m OpenAL Soft [0m[90m::::::::::::::::::::::::::::::::::::[0m"
echo.
EXIT /B 0


::Register dsound.dll
:RegisterDSound
echo Registering DirectSound references (dsound.dll)...
	::Check reference 1/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "[92mDirectSound interface reference 1/4 has been found in the registry.[0m"
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "[93mDirectSound interface reference 1/4 has not been found. Added to the registry.[0m"
	 	)
	::Check reference 2/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "[92mDirectSound interface reference 2/4 has been found in the registry.[0m"
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "[93mDirectSound interface reference 2/4 has not been found. Added to the registry.[0m"
	 	)
	::Check reference 3/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "[92mDirectSound interface reference 3/4 has been found in the registry.[0m"
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "[93mDirectSound interface reference 3/4 has not been found. Added to the registry.[0m"
	 	)
	::Check reference 4/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "[92mDirectSound interface reference 4/4 has been found in the registry.[0m"
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "[93mDirectSound interface reference 4/4 has not been found. Added to the registry.[0m"
	 	)
echo.
EXIT /B 0
::Required by DSOAL on Windows 8+ for games to load dsound.dll from their own folder.
::Source: https://www.indirectsound.com/registryIssues.html


::Automatic configuration - General
:AutoConfigGeneral
call :PrintAndLog "Applying automatic configuration..."
	::Get default playback device name
	"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /scomma "%UserFilesFolder%\AudioDevices.csv"
	for /f "tokens=4 delims=," %%a in ('type "%UserFilesFolder%\AudioDevices.csv" ^| find "Render,Render"') do set "DefaultPlaybackDevice=%%a"
	del "%UserFilesFolder%\AudioDevices.csv"
	::Set sample rate to 48khz and bit depth to 24 bit
	"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetDefaultFormat "%DefaultPlaybackDevice%\Device\Speakers\Render" 24 48000
	call :PrintAndLog "[92mDefault playback device's format has been set to 24 bit, 48000hz.[0m"
EXIT /B 0

::Automatic configuration - DSOAL
:AutoConfigDSOAL
	::Toggle exclusive mode depending on selected branch
	IF "%OpenALSoftDSOALBranch%"=="WASAPI" (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		call :PrintAndLog "[92mExclusive mode has been enabled.[0m"
		) else (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		call :PrintAndLog "[92mExclusive mode has been disabled.[0m"
		)
	::Deactivate other audio effects unless WASAPI was selected
	IF NOT "%OpenALSoftDSOALBranch%"=="WASAPI" (
		::Disable Windows spatial sound
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetSpatial "%DefaultPlaybackDevice%\Device\Speakers\Render" ""
		call :PrintAndLog "[92mWindows spatial sound has been disabled.[0m"
		::Disable HeSuVi
		IF EXIST %HeSuViPath% (
			%HeSuViPath% -deactivateeverything 1
			call :PrintAndLog "[92mHeSuVi has been disabled.[0m"
			)
		)
	echo.
EXIT /B 0

::Automatic configuration - OpenAL Soft
:AutoConfigOpenALSoft
	::Toggle exclusive mode depending on selected branch
	IF "%OpenALSoftBranch%"=="WASAPI" (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		call :PrintAndLog "[92mExclusive mode has been enabled.[0m"
		) else (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		call :PrintAndLog "[92mExclusive mode has been disabled.[0m"
		)
	::Deactivate other audio effects unless WASAPI was selected
	IF NOT "%OpenALSoftBranch%"=="WASAPI" (
		::Disable Windows spatial sound
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetSpatial "%DefaultPlaybackDevice%\Device\Speakers\Render" ""
		call :PrintAndLog "[92mWindows spatial sound has been disabled.[0m"
		::Disable HeSuVi
		IF EXIST %HeSuViPath% (
			%HeSuViPath% -deactivateeverything 1
			call :PrintAndLog "[92mHeSuVi has been disabled.[0m"
			)
		)
	echo.
EXIT /B 0


::Log cleanup
:CleanupLog
"Resources\Tools\FART\fart.exe" %LogFilePath% C:\Users\%USERNAME%\ C:\Users\USERNAME\ > NUL
EXIT /B 0


::Print and log
:PrintAndLog
echo %~1
echo %~1 >>%LogFilePath%
EXIT /B 0


::Log reporting
:ReportLog
call :CleanupLog
call :PrintAndLog "If the issue persists, please report the Log from %UserFilesFolder%/ to our chat: %ChatURL%"
call :PrintAndLog "Continue to the chat in your browser? Otherwise close this window."
pause
start %UserFilesFolder%
start %ChatURL%
exit


::DSOAL failure
:DSOALFailure
call :PrintAndLog "[91mDSOAL [1mv%DSOALVersion%[0m installation has failed![0m"
call :PrintAndLog "Please run the script again."
call :ReportLog
pause
exit


::OpenAL Soft failure
:OpenALSoftFailure
call :PrintAndLog "[91mPlease run the script again as an administrator.[0m"
call :ReportLog
pause
exit