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
	SET GamePath=%~d1%~p1
	::General
	SET ScriptVersion=1.4
	SET CurrentDate=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%
	SET CurrentDate=%CurrentDate: =0%
	SET UserFilesFolder=UserFiles
	SET BackupPath=%UserFilesFolder%\Backup\Backup_%CurrentDate%
	SET LogFilePath=%UserFilesFolder%\Log.txt
	::External
	SET HeSuViPath="C:\Program Files\EqualizerAPO\config\HeSuVi\HeSuVi.exe"
	SET ChatURL=https://kutt.it/U3DAMChat

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
	::Drag and drop check
	IF DEFINED GamePath (
		::Check if selected DSOAL version and branch exists
		IF NOT EXIST %DSOALSetupFolder% (
			call :PrintAndLog "The folder for the selected DSOAL version and branch does not exist."
			call :PrintAndLog "Please make sure that the variable DSOALVersion is set to the right value."
			pause
			exit
		)

		::Check if selected OpenAL Soft version and branch exists
		IF NOT EXIST %OpenALSoftDSOALSetupFolder% (
			call :PrintAndLog "The folder for the selected OpenAL Soft DSOAL version and branch does not exist."
			call :PrintAndLog "Please make sure that the variables OpenALSoftDSOALVersion and OpenALSoftDSOALBranch are set to the right values."
			pause
			exit
		)

		::Info
		call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		call :PrintAndLog ":::::::::::::::::::::::::: UniversAL 3D Audio Manager v%ScriptVersion% ::::::::::::::::::::::::::"
		call :PrintAndLog ":::::::::::::::: By 3DJ - github.com/ThreeDeeJay / @Discord 3DJ#5426 ::::::::::::::::"
		call :PrintAndLog "::::: Script that automates enabling 3D audio in OpenAL and DirectSound3D games :::::"
		call :PrintAndLog "::::::::::::::::::::::: H E A D P H O N E S   R E Q U I R E D :::::::::::::::::::::::"
		call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		echo.
		call :PrintAndLog "- DSOAL version: %DSOALVersion%"
		call :PrintAndLog "- OpenAL Soft version: %OpenALSoftDSOALVersionBranch%"
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
		cls

		::Info
		call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		call :PrintAndLog ":::::::::::::::::::::::::: UniversAL 3D Audio Manager v%ScriptVersion% ::::::::::::::::::::::::::"
		call :PrintAndLog "::::::::::::::::::::::::::::::::::::::: DSOAL :::::::::::::::::::::::::::::::::::::::"
		echo.

		::Backup DSOAL
		call :PrintAndLog "Backing up DSOAL..."
			::Create game backup folder
			IF NOT EXIST %BackupPath%\GameExeFolder (
				mkdir %BackupPath%\GameExeFolder
				)
			::Backup dsound.dll
			IF EXIST "%GamePath%\dsound.dll" (
				copy "%GamePath%\dsound.dll" "%BackupPath%\GameExeFolder\dsound.dll" >>%LogFilePath%
				del "%GamePath%\dsound.dll" >>%LogFilePath%
				)
			::Backup dsoal-aldrv.dll
			IF EXIST "%GamePath%\dsoal-aldrv.dll" (
				copy "%GamePath%\dsoal-aldrv.dll" "%BackupPath%\GameExeFolder\dsoal-aldrv.dll" >>%LogFilePath%
				del "%GamePath%\dsoal-aldrv.dll" >>%LogFilePath%
				)
			::Backup alsoft.ini
			IF EXIST "%GamePath%\alsoft.ini" (
				copy "%GamePath%\alsoft.ini" "%BackupPath%\GameExeFolder\alsoft.ini" >>%LogFilePath%
				del "%GamePath%\alsoft.ini" >>%LogFilePath%
				)
			::Backup OpenAL folder
			IF EXIST "%GamePath%\OpenAL" (
				xcopy "%GamePath%\OpenAL" "%BackupPath%\GameExeFolder\OpenAL\"  /s /y >>%LogFilePath%
				rmdir /s /q "%GamePath%\OpenAL\"
				)
		call :PrintAndLog "DSOAL has been successfully backed up!"
		echo.

		::Install DSOAL
		call :PrintAndLog "Installing DSOAL into the game folder..."
			::Install HRTF folder
			IF EXIST "%OpenALSoftHRTFFolder%" (
				xcopy "%OpenALSoftHRTFFolder%" "%GamePath%\OpenAL\HRTF\"  /s /y >>%LogFilePath%
			) else (
				xcopy "Resources\Common\OpenAL\HRTF" "%GamePath%\OpenAL\HRTF\"  /s /y >>%LogFilePath%
			)
			::Install presets folder
			IF EXIST "%OpenALSoftPresetsFolder%" (
				xcopy "%OpenALSoftPresetsFolder%" "%GamePath%\OpenAL\presets\"  /s /y >>%LogFilePath%
			) else (
				xcopy "Resources\OpenALSoft\%OpenALSoftVersion%\APPDATA\OpenAL\presets" "%GamePath%\OpenAL\presets\"  /s /y >>%LogFilePath%
			)
			::Install dsound.dll
			copy "Resources\DSOAL\%DSOALVersion%\GameExeFolder\dsound.dll" "%GamePath%\dsound.dll" >>%LogFilePath%
			::Install dsoal-aldrv.dll
			copy "Resources\OpenALSoft\%OpenALSoftDSOALVersionBranch%\APPDATA\OpenAL\bin\Win32\soft_oal.dll" "%GamePath%\dsoal-aldrv.dll" >>%LogFilePath%
			::Install alsoft.ini
			IF EXIST "%OpenALSoftINIPath%" (
				copy "%OpenALSoftINIPath%" "%GamePath%\alsoft.ini" >>%LogFilePath%
				) else (
				copy "Resources\Common\alsoft.ini" "%GamePath%\alsoft.ini" >>%LogFilePath%
				)
			IF "%OpenALSoftDSOALBranch%"=="WASAPI" (
				::Period size
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General period_size 160 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Periods
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General periods 1 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Sample type
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General sample-type int16 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Drivers
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General drivers "wasapi," > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
			) else (
				::Period size
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General period_size 1024 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Periods
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General periods 3 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Sample type
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General sample-type float32 > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
				::Drivers
				Resources\Tools\initool\initool.exe s "%GamePath%\alsoft.ini" General drivers "-dsound," > "%GamePath%\alsoft.ini.temp"
				move /y "%GamePath%\alsoft.ini.temp" "%GamePath%\alsoft.ini" >>%LogFilePath%
			)

		::Confirmation
		IF EXIST "%GamePath%\OpenAL\HRTF" (
			IF EXIST "%GamePath%\OpenAL\presets" (
				IF EXIST "%GamePath%\dsound.dll" (
					IF EXIST "%GamePath%\dsoal-aldrv.dll" (
						IF EXIST "%GamePath%\alsoft.ini" (
							call :PrintAndLog "DSOAL %DSOALVersion% has been successfully installed!"
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
		call :PrintAndLog ":::::::::::::::::::: Installation complete! ::::::::::::::::::::"
		call :PrintAndLog "The selected game is now 3D audio-capable. "
		call :PrintAndLog "Make sure to enable DirectSound3D/EAX/Hardware acceleration options in-game if necessary."
		call :PrintAndLog "Also, remember to disable any other audio effects, except for headphones equalization if needed."
		echo.
		pause
		exit
		)

::OpenAL Soft
	::Check for admin privileges
	IF EXIST %SYSTEMROOT%\SYSTEM32\WDI\LOGFILES GOTO GOTADMIN
	call :PrintAndLog "Please close this window then right click this .bat file and Run as administrator"
	call :PrintAndLog "so the script can copy required files to the system."
	pause
	exit
	:GOTADMIN

	::Check if selected OpenAL Soft version and branch exists
	IF NOT EXIST %OpenALSoftSetupFolder% (
		call :PrintAndLog "The folder for the selected OpenAL Soft version and branch does not exist."
		call :PrintAndLog "Please make sure that the variables OpenALSoftVersion and OpenALSoftBranch are set to the right values."
		pause
		exit
	)

	::Info
	call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
	call :PrintAndLog ":::::::::::::::::::::::::: UniversAL 3D Audio Manager v%ScriptVersion% ::::::::::::::::::::::::::"
	call :PrintAndLog ":::::::::::::::: By 3DJ - github.com/ThreeDeeJay / @Discord 3DJ#5426 ::::::::::::::::"
	call :PrintAndLog "::::: Script that automates enabling 3D audio in OpenAL and DirectSound3D games :::::"
	call :PrintAndLog "::::::::::::::::::::::: H E A D P H O N E S   R E Q U I R E D :::::::::::::::::::::::"
	call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
	echo.
	call :PrintAndLog "- OpenAL Soft version: %OpenALSoftVersionBranch%"
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
	cls

	::Info
	call :PrintAndLog ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
	call :PrintAndLog ":::::::::::::::::::::::::: UniversAL 3D Audio Manager v%ScriptVersion% ::::::::::::::::::::::::::"
	call :PrintAndLog ":::::::::::::::::::::::::::::::::::: OpenAL Soft ::::::::::::::::::::::::::::::::::::"
	echo.

	::Install OpenAL redistributable
	call :PrintAndLog "Installing OpenAL..."
	Resources\OpenAL\Installer\oalinst.exe /SILENT >>%LogFilePath%
	IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
		IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
			call :PrintAndLog "OpenAL has been successfully installed!"
			) else (
			call :PrintAndLog "OpenAL installation has failed!"
			goto OpenALSoftFailure
			)
		) else (
		call :PrintAndLog "OpenAL installation has failed!"
		goto OpenALSoftFailure
		)
	echo.
	::Required by OpenAL Soft
	::Source: https://openal.org/downloads/

	::Backup OpenAL Soft
	call :PrintAndLog "Backing up OpenAL Soft..."
		::Backup HRTF folder
		IF EXIST "%OpenALSoftHRTFFolder%" (
			xcopy "%OpenALSoftHRTFFolder%" "%BackupPath%\APPDATA\OpenAL\HRTF\"  /s /y >>%LogFilePath%
			rmdir /s /q "%OpenALSoftHRTFFolder%" >>%LogFilePath%
			call :PrintAndLog "OpenAL Soft HRTF folder has been found. Moved to the Backup folder."
		)
		::Backup OpenAL folder
		IF EXIST "%OpenALSoftInstallationFolder%" (
			xcopy "%OpenALSoftInstallationFolder%" "%BackupPath%\APPDATA\OpenAL\"  /s /y >>%LogFilePath%
			rmdir /s /q "%OpenALSoftInstallationFolder%" >>%LogFilePath%
			call :PrintAndLog "OpenAL Soft installation folder has been found. Moved to the Backup folder."
			)
		::Backup alsoft.ini
		IF EXIST "%OpenALSoftINIPath%" (
			copy "%OpenALSoftINIPath%" "%BackupPath%\APPDATA\alsoft.ini" >>%LogFilePath%
			del "%OpenALSoftINIPath%" >>%LogFilePath%
			call :PrintAndLog "OpenAL Soft configuration file has been found. Moved to the Backup folder."
			)
		::Backup OpenAL32.dll (32-bit)
		IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
			mkdir "%BackupPath%\WINDIR\SysWOW64" >>%LogFilePath%
			copy "%WINDIR%\%OpenALDLLx32Path%" "%BackupPath%\WINDIR\%OpenALDLLx32Path%" >>%LogFilePath%
			del "%WINDIR%\%OpenALDLLx32Path%" >>%LogFilePath%
			call :PrintAndLog "OpenAL 32-bit DLL file has been found. Moved to the Backup folder."
			)
		::Backup OpenAL32.dll (64-bit)
		IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
			mkdir "%BackupPath%\WINDIR\System32" >>%LogFilePath%
			copy "%WINDIR%\%OpenALDLLx64Path%" "%BackupPath%\WINDIR\%OpenALDLLx64Path%" >>%LogFilePath%
			del "%WINDIR%\%OpenALDLLx64Path%" >>%LogFilePath%
			call :PrintAndLog "OpenAL 64-bit DLL file has been found. Moved to the Backup folder."
			)

	::Backup confirmation
	IF EXIST "%BackupPath%" (
		call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% has been successfully backed up!"
		) else (
			call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% backup has failed!"
			goto OpenALSoftFailure
		)
	echo.

	::Install OpenAL Soft
	call :PrintAndLog "Installing OpenAL Soft %OpenALSoftVersion%..."
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

	::Confirmation
	IF EXIST "%OpenALSoftInstallationFolder%" (
		IF EXIST "%OpenALSoftHRTFFolder%" (
			IF EXIST "%OpenALSoftINIPath%" (
				IF EXIST "%WINDIR%\%OpenALDLLx32Path%" (
					IF EXIST "%WINDIR%\%OpenALDLLx64Path%" (
						call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% has been successfully installed!"
						) else (
							call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% installation has failed!"
							goto OpenALSoftFailure
						)
					) else (
						call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% installation has failed!"
						goto OpenALSoftFailure
					)
				) else (
					call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% installation has failed!"
					goto OpenALSoftFailure
				)
			) else (
				call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% installation has failed!"
				goto OpenALSoftFailure
			)
		) else (
			call :PrintAndLog "OpenAL Soft %OpenALSoftVersion% installation has failed!	"
			goto OpenALSoftFailure
		)
	echo.

call :AutoConfigGeneral
call :AutoConfigOpenALSoft

call :CleanupLog

::Complete
echo :::::::::::::::::::: Installation complete! ::::::::::::::::::::
echo Log and Backup folder are located in %UserFilesFolder%\
echo Also, remember to disable any other audio effects, except for headphones equalization if needed.
echo Press any key to run the configuration tool in case you need to set your Preferred HRTF in the HRTF tab.
echo Otherwise, close this window.
echo.
pause
start %OpenALSoftInstallationFolder%\alsoft-config\alsoft-config.exe
exit





::Register dsound.dll
:RegisterDSound
echo Registering DirectSound references (dsound.dll)...
::::start regedit /s "Resources\DirectSound\RegisterDLL.reg" >>%LogFilePath%
	::Check reference 1/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "DirectSound interface reference 1/4 has been found in the registry."
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "DirectSound interface reference 1/4 has been added to the registry."
	 	)
	::Check reference 2/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "DirectSound interface reference 2/4 has been found in the registry."
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "DirectSound interface reference 2/4 has been added to the registry."
	 	)
	::Check reference 3/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "DirectSound interface reference 3/4 has been found in the registry."
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{47D4D946-62E8-11CF-93BC-444553540000}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "DirectSound interface reference 3/4 has been added to the registry."
	 	)
	::Check reference 4/4
	reg query HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 1> NUL 2>&1
	if %errorlevel% equ 0 (
	 	call :PrintAndLog "DirectSound interface reference 4/4 has been found in the registry."
	 	) else (
	 	reg add HKEY_CURRENT_USER\SOFTWARE\Classes\Wow6432Node\CLSID\{3901CC3F-84B5-4FA4-BA35-AA8172B8A09B}\InprocServer32 /t REG_SZ /d dsound.dll 1> NUL 2>&1
	 	call :PrintAndLog "DirectSound interface reference 4/4 has been added to the registry."
	 	)
echo.
::Required by DSOAL on Windows 8+ for games to load dsound.dll from their own folder.
::Source: https://www.indirectsound.com/registryIssues.html
EXIT /B 0


::Automatic configuration - General
:AutoConfigGeneral
call :PrintAndLog "Applying automatic configuration..."
	::Get default playback device name
	"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /scomma "%UserFilesFolder%\AudioDevices.csv"
	for /f "tokens=4 delims=," %%a in ('type "%UserFilesFolder%\AudioDevices.csv" ^| find "Render,Render"') do set "DefaultPlaybackDevice=%%a"
	del "%UserFilesFolder%\AudioDevices.csv"
	::Set sample rate to 48khz and bit depth to 24 bit
	"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetDefaultFormat "%DefaultPlaybackDevice%\Device\Speakers\Render" 24 48000
	call :PrintAndLog "Default playback device's format has been set to 24 bit, 48000hz."
EXIT /B 0

::Automatic configuration - DSOAL
:AutoConfigDSOAL
	::Toggle exclusive mode depending on selected branch
	IF "%OpenALSoftDSOALBranch%"=="WASAPI" (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 1
		call :PrintAndLog "Exclusive mode has been enabled."
		) else (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		call :PrintAndLog "Exclusive mode has been disabled."
		)
	::Deactivate other audio effects unless WASAPI was selected
	IF NOT "%OpenALSoftDSOALBranch%"=="WASAPI" (
		::Disable Windows spatial sound
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetSpatial "%DefaultPlaybackDevice%\Device\Speakers\Render" ""
		call :PrintAndLog "Windows spatial sound has been disabled."
		::Disable HeSuVi
		IF EXIST %HeSuViPath% (
			%HeSuViPath% -deactivateeverything 1
			call :PrintAndLog "HeSuVi has been disabled."
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
		call :PrintAndLog "Exclusive mode has been enabled."
		) else (
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetAllowExclusive "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetExclusivePriority "%DefaultPlaybackDevice%\Device\Speakers\Render" 0
		call :PrintAndLog "Exclusive mode has been disabled."
		)
	::Deactivate other audio effects unless WASAPI was selected
	IF NOT "%OpenALSoftBranch%"=="WASAPI" (
		::Disable Windows spatial sound
		"Resources\Tools\SoundVolumeView\SoundVolumeView.exe" /SetSpatial "%DefaultPlaybackDevice%\Device\Speakers\Render" ""
		call :PrintAndLog "Windows spatial sound has been disabled."
		::Disable HeSuVi
		IF EXIST %HeSuViPath% (
			%HeSuViPath% -deactivateeverything 1
			call :PrintAndLog "HeSuVi has been disabled."
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
call :PrintAndLog "DSOAL %DSOALVersion% installation has failed!"
call :PrintAndLog "Please run the script again."
call :ReportLog
pause
exit


::OpenAL Soft failure
:OpenALSoftFailure
call :PrintAndLog "Please run the script again as an administrator."
call :ReportLog
pause
exit