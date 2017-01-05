# Powershell video deshaker script generator
Using Gunnar Thalin's excellent [Deshaker-plugin](http://www.guthspot.se/video/deshaker.htm) can be tedious because of settings. This script generates the necessary AviSynth and VirtualDub-scripts with some default-settings so that it can be done in a single stroke. 

## Requirements
1. VirtualDub x86-version
2. Deshaker-plugin x86-version
3. Avisynth [^2.6](https://sourceforge.net/projects/avisynth2/files/latest/download)
4. For go pro MP4 support FFMPEG DLLs are needed [FFMS ^2](https://github.com/FFMS/ffms2/releases)
5. Move files from `ffm2-2.20-icl/x86` to `Program Files (x86)/AviSynth 2.5/plugins`

## Usage
Common use case there is little more to it than:

1. Run the command in Powershell
  * `PS> .\deshake.ps1 C:\**\GOPR0260.MP4`
2. The first time around this starts VirtualDub and start reporting on total number of frames via the AviSynth-logger. The file is called `deshake.GOPR0260.stats.log`.
3. Close VirtualDub as soon as it starts processing the file.
4. Run the script again 
  * `PS> .\deshake.ps1 C:\**\GOPR0260.MP4`.
5. This time around a total of six scripts have been created.
  * deshake.GOPR0260.all.jobs
  * deshake.GOPR0260.framecount.avs
  * deshake.GOPR0260.framecount.script
  * deshake.GOPR0260.pass1.avs
  * deshake.GOPR0260.pass2.avs
  * deshake.GOPR0260.stats.log
6. Open VirtualDub and select *Job Control* in the *File*-menu.
7. Navigate to the location of scripts and open *deshake.GOPR0260.all.jobs*

## Joining multiple clips to one

1. Create a job as per usual i.e:
  * `PS > .\deshake.ps1 C:\**\GOPR0260.MP4`
2. Interupt the framecounter once a total number of frames has been captured 
3. Change number of scripts by adding additional sources with *FFAudioSource* and *FFVideoSource*
4. Splice them together with *AudioDub* and *AlignedSplice*. 
5. Simulating color correction in dark scenarios using the following `Tweak(sat=1.20)` and `Levels(25, 1.33, 245, 0, 255)`

### Example below

	LoadVirtualDubPlugin ("C:\devwork\ps-avisynth-deshake\Deshaker.vdf", "deshaker", preroll=0)
	A1 = FFAudioSource("X:\2016-11-06\HERO5 Black 2\260\GOPR0260.MP4")
	V1 = FFVideoSource("X:\HERO5 Black 2\260\GOPR0260.MP4")
	A2 = FFAudioSource("X:\HERO5 Black 2\260\GP010260.MP4")
	V2 = FFVideoSource("X:\HERO5 Black 2\260\GP010260.MP4")
	# AlignedSplice(AudioDub(V1, A1).ConvertToRGB32(matrix="PC.709"),AudioDub(V2, A2).ConvertToRGB32(matrix="PC.709"))
	AlignedSplice(AudioDub(V1, A1),AudioDub(V2, A2))
	Trim(28853, 29508)
	ConvertToYUY2()
	Tweak(sat=1.20)
	Levels(25, 1.33, 245, 0, 255)
	# Deshaker("19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|3|2|8|30|300|4|C:\\usr\\xyz\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|10|10|5|10|0|0|30|30|0|0|1|0|1|1|0|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff")

## Additional info
1. [Blog post](http://abarry.org/avisynth-virtualdub-linux-gopro-hero-4-black-120fps-video/
) on how to do this on linux with WINE
2. http://avisynth.nl/index.php/FAQ_loading_clips
