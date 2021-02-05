# UniversAL 3D Audio Manager
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FThreeDeeJay%2FUniversAL-3D-Audio-Manager.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FThreeDeeJay%2FUniversAL-3D-Audio-Manager?ref=badge_shield)

 Script that automates enabling 3D audio in [OpenAL & DirectSound3D games](https://airtable.com/shrYxQRtC15KgpEo0/tblNOTdmp5nHXfFGU).  
[Direct download](https://kutt.it/U3DAMDirectDownload)  
[Binaural audio in a nutshell](https://kutt.it/binaural)

# Guide
To enable 3D audio in [OpenAL games](https://airtable.com/shr1cvMcBqudWtjuP):  
Right-click **UniversAL 3D Audio Manager.bat** > Run as administrator.  
Then the script will:
- Backup and/or (re)install OpenAL Soft.
- Install OpenAL redistributable.
- Update OpenAL DLLs in the Windows folder.
- Set default playback device's format to 24 bit, 48000hz.
- Disable (unless WASAPI is selected):
    - Exclusive Mode
    - Windows spatial sound
    - HeSuVi  

To enable 3D audio in [DirectSound3D games](https://airtable.com/shrX9CnU32R6V1AHw):  
Drag and drop a game (or program) executable (.exe that's usually in a folder with DLL files) into the .bat script.  
Then the script will:
- Backup and/or (re)install DSOAL using existing OpenAL Soft global settings.
- Set default playback device's format to 24 bit, 48000hz.
- Disable (unless WASAPI is selected):
    - Exclusive Mode
    - Windows spatial sound
    - HeSuVi
- Fix DirectSound references in the registry.  

# Contact
For more updates, troubleshooting or contribution, join the discussion at the [3D Game Audio Discord server](https://kutt.it/U3DAMChat).  

# Credits:  
[Creative](https://en.wikipedia.org/wiki/Aureal_Semiconductor#History) - [OpenAL](https://openal.org/)  
[kcat](https://github.com/kcat) - [OpenAL Soft](https://github.com/kcat/openal-soft) & [DSOAL](https://github.com/kcat/dsoal)  
[I Drink Lava](https://www.youtube.com/channel/UCGrS-9TNYTo-gp3pjrA6VDg) - [DSOAL v1.31a setup](https://www.nexusmods.com/newvegas/mods/65094)  
[dbohdan](https://github.com/dbohdan) - [initool](https://github.com/dbohdan/initool)  
[Nirsoft](https://www.nirsoft.net/) - [SoundVolumeView](https://www.nirsoft.net/utils/sound_volume_view.html)  
[Soepy](https://sourceforge.net/u/soepy/) - [Find And Replace Text](https://sourceforge.net/projects/fart-it/)  


## License
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FThreeDeeJay%2FUniversAL-3D-Audio-Manager.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FThreeDeeJay%2FUniversAL-3D-Audio-Manager?ref=badge_large)