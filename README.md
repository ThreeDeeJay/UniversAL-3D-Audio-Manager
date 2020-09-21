# UniversAL 3D Audio Manager
 Script that automates enabling 3D audio in OpenAL and DirectSound3D games.  
[OpenAL & DirectSound3D games list](https://airtable.com/shrYxQRtC15KgpEo0/tblNOTdmp5nHXfFGU)  
[Direct download](https://kutt.it/U3DAMDirectDownload)

To enable 3D audio in [OpenAL games](https://airtable.com/shr1cvMcBqudWtjuP):  
Right-click **UniversAL 3D Audio Manager.bat** > Run as administrator.  
Then the script will:
- Backup and/or (re)install OpenAL Soft.
- Update OpenAL DLLs in the Windows folder.
- Set default playback device's format to 24 bit, 48000hz.
- Disable (unless WASAPI is selected):
    - Exclusive Mode
    - Windows spatial sound
    - HeSuVi

To enable 3D audio in [DirectSound3D games](https://airtable.com/shrX9CnU32R6V1AHw):  
Drag and drop a game (or program) executable (.exe that's usually in a folder with DLL files) into the .bat script.  
Then the script will:
- Install OpenAL redistributable.
- Backup and/or (re)install DSOAL using existing OpenAL Soft global settings.
- Set default playback device's format to 24 bit, 48000hz.
- Disable (unless WASAPI is selected):
    - Exclusive Mode
    - Windows spatial sound
    - HeSuVi
- Fix DirectSound references in the registry.

For more updates, troubleshooting or contribution, join the discussion at the [3D Game Audio Discord server](https://discord.gg/RhRMbmQ).

Credits:  
[Creative](https://en.wikipedia.org/wiki/Aureal_Semiconductor#History) - [OpenAL](https://openal.org/)  
[kcat](https://github.com/kcat) - [OpenAL Soft](https://github.com/kcat/openal-soft) & [DSOAL](https://github.com/kcat/dsoal)  
[I Drink Lava](https://www.youtube.com/channel/UCGrS-9TNYTo-gp3pjrA6VDg) - [DSOAL v1.31a setup](https://www.nexusmods.com/newvegas/mods/65094)  
[dbohdan](https://github.com/dbohdan) - [initool](https://github.com/dbohdan/initool)  
[Nirsoft](https://www.nirsoft.net/) - [SoundVolumeView](https://www.nirsoft.net/utils/sound_volume_view.html)
