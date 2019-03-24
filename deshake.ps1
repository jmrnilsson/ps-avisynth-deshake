[CmdletBinding()]

Param
(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$name
)

# MVI_2126.MOV
$path = "C:\video\"
#$path_wine = Join-Path -Path '/root/.wine/drive_c/video/' -ChildPath $path
$path_video = Join-Path -Path '/video/' -ChildPath $path


# If (!$(Test-Path $path_video))
# {
#     Write-Error "'{0}' doesn't exist" -f $path_video
#     exit 10
# }
# ElseIf ($(Get-ChildItem $path_video).PSIsContainer)
# {
#     Write-Error "Merge not supported at this time"
#     exit 20
#     $files = Get-ChildItem $path | ?{ !$_.PSIsContainer } | foreach { $_.FullName }
# }
# Else
If ($path)
{
    # $name = $(Get-ChildItem $path).BaseName # | $_.Name
    # $outDirectory = $(Get-ChildItem $path).Directory.FullName
    # $outDirectory = 'C:\video'
    # $output = Get-ChildItem $path | ForEach-Object { $_.BaseName + '.' +  ($(get-date -format s) -replace ':|-', '') + '.AVI' }
    # $outFullName = $($outDirectory + '\' + $output)
    $outFullName = $("C:\video\$name." + ($(get-date -format s) -replace ':|-', '') + '.AVI')

    Write-Output $('path={2}, name={0}, output={1}. input={2}' -f $name, $output, $outFullName, $path)
}

$log = $('deshake.{0}.stats.log' -f $name)
Write-Output "PWD=$PWD, FrameCounterLogFile=$log"

If (!$(Test-Path $log))
{
    $script3 = $('deshake.{0}.framecount.avs' -f $name)
    $script0 = $('deshake.{0}.framecount.script' -f $name)
    $script3_win = $("C:\video\$script3")
    $script0_win = $("C:\video\$script0")
    $script3_wine = $("/root/.wine/drive_c/video/$script3")
    $script0_wine = $("/root/.wine/drive_c/video/$script0")

    $wineVideoPath = 'C:\video'
    ((Get-Content 'deshake.template.framecount.avs') | Out-String) -f $path, $($wineVideoPath + '\' + $log) | Set-Content $script3_wine
    ((Get-Content 'deshake.template.framecount.script') | Out-String) -f $($wineVideoPath + '\' + $script3) -replace '\\', '\\' | Set-Content $script0_wine
    Write-Output 'Counting number of frames..'
    $(nohup xvfb-run -a wine ./virtualdub/VirtualDub.exe /x /s $($script0_win) | Out-Null)
}

$script1 = $('deshake.{0}.pass1.avs' -f $name)
$script2 = $('deshake.{0}.pass2.avs' -f $name)
$script1_wine = $("/root/.wine/drive_c/video/$script1")
$script2_wine = $("/root/.wine/drive_c/video/$script2")

(Get-Content 'deshake.template.pass1.avs') -replace '\[0\]', $path | Set-Content $script1_wine
(Get-Content 'deshake.template.pass2.avs') -replace '\[0\]', $path | Set-Content $script2_wine

$frameCount = ((Get-Content $log) -match '\d+')[1]

$scriptFullName1 = (gci $script1).FullName -replace '\\', '\\'
$scriptFullName2 = (gci $script2).FullName -replace '\\', '\\'
$out = $outFullName -replace '\\', '\\'

((Get-Content 'deshake.template.jobs') | Out-String) -f $scriptFullName1, $scriptFullName2, $out, $frameCount | Set-Content $('deshake.{0}.all.jobs' -f $name)
