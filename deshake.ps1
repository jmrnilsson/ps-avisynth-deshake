[CmdletBinding()]

Param
(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$cmd
)

Function New-FrameCountAvs()
{
    Param
    (
       [Parameter(Mandatory=$True,Position=1)]
       [string]$name
    )

    Return "A1 = FFAudioSource(""C:\video\${name}"")`r`n"
        + "V1 = FFVideoSource(""C:\video\${name}"")`r`n"
        + "AudioDub(V1, A1).ConvertToRGB32(matrix=""PC.709"")`r`n"
        + " # Trim(3000, 3750)`r`n"
        + "WriteFile(""deshake.${name}.stats.log"", ""FrameCount"")`r`n"    
}

Function New-FrameCountScript()
{
    Param
    (
       [Parameter(Mandatory=$True,Position=1)]
       [string]$name
    )

    Return "VirtualDub.Open(""C:\\deshake.${name}.framecount.avs"","",0);`r`n"
        + "VirtualDub.RunNullVideoPass();`r`n"
        + "VirtualDub.Close();`r`n"
}

Function New-Pass1()
{
    Param
    (
       [Parameter(Mandatory=$True,Position=1)]
       [string]$name
    )

    Return "LoadVirtualDubPlugin (""C:\Program Files\AviSynth\Deshaker.vdf"", ""deshaker"", preroll=0)`r`n"
        + "A1 = FFAudioSource(""[0]"")`r`n"
        + "V1 = FFVideoSource(""[0]"")`r`n"
        + "AudioDub(V1, A1).ConvertToRGB32(matrix=""PC.709"")`r`n"
        + "# Trim(3000, 3750)`r`n"
        + "# Deshaker(""19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|3|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|10|10|5|10|0|0|30|30|0|0|1|0|1|1|0|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "# Deshaker(""19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|3|2|8|99|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|5|1|1|30|30|0|0|1|0|1|1|0|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")Deshaker(""19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|1|2|# Deshaker(""19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|1|2|8|99|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|5|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "Deshaker(""19|1|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|0|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|15|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
}

Function New-Pass2()
{
    Param
    (
       [Parameter(Mandatory=$True,Position=1)]
       [string]$name
    )

    Return "SetMemoryMax(500)`r`n"
        + "LoadVirtualDubPlugin (""C:\Program Files\AviSynth\Deshaker.vdf"", ""deshaker"", preroll=0)`r`n"
        + "A1 = FFAudioSource(""[0]"")`r`n"
        + "V1 = FFVideoSource(""[0]"")`r`n"
        + "AudioDub(V1, A1).ConvertToRGB32(matrix=""PC.709"")`r`n"
        + "# Trim(3000, 3750)`r`n"
        + "# Deshaker(""19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|3|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|10|10|5|10|0|0|30|30|0|0|1|0|1|1|0|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "# Deshaker(""19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|3|2|8|99|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|5|1|1|30|30|0|0|1|0|1|1|0|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "# Deshaker(""19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|1|2|8|99|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|5|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "Deshaker(""19|2|30|4|1|0|1|0|640|480|1|2|1000|1000|1000|1000|4|1|0|2|8|30|300|4|M:\\usr\\FOTO\\\GOPROWORKDIR\\Deshaker.log|0|0|0|0|0|0|0|0|0|0|0|0|0|1|15|15|10|15|1|1|30|30|0|0|1|0|1|1|1|10|1000|1|90|1|1|20|5000|100|20|1|0|ff00ff"")`r`n"
        + "ConvertToYV12()`r`n"
}



# MVI_2126.MOV
$name = $cmd -replace ".\w+$", ""
Write-Output "cmd=$cmd, name=$name"
$path = "C:\video\"
If ($path)
{
    # $name = $(Get-ChildItem $path).BaseName # | $_.Name
    # $outDirectory = $(Get-ChildItem $path).Directory.FullName
    # $outDirectory = 'C:\video'
    # $output = Get-ChildItem $path | ForEach-Object { $_.BaseName + '.' +  ($(get-date -format s) -replace ':|-', '') + '.AVI' }
    # $outFullName = $($outDirectory + '\' + $output)
    $tag = $(Get-Date -Format FileDateTimeUniversal).replace("T", ".").Substring(0, 13)
    $output = $("C:\video\$name.$tag.avi")

    Write-Output "output=$output"
}

$log = $('deshake.{0}.stats.log' -f $name)
Write-Output "PWD=$PWD, FrameCounterLogFile=$log"

If (!$(Test-Path $log))
{
    $script0 = "deshake.$name.framecount.script"
    $script3 = "deshake.$name.framecount.avs"
    
    ((Get-Content 'deshake.template.framecount.avs') `
        | Out-String) `
        | Set-Content "/root/.wine/drive_c/video/$script3"
    ((Get-Content 'deshake.template.framecount.script') `
        | Out-String) `
        | Set-Content "/root/.wine/drive_c/video/$script0"

    Write-Output 'Counting number of frames..'
    $(nohup xvfb-run -a wine ./virtualdub/VirtualDub.exe /x /s $("C:\video\$script0") | Out-Null)
}

$script1 = $('deshake.{0}.pass1.avs' -f $name)
$script2 = $('deshake.{0}.pass2.avs' -f $name)
$script1_wine = $("/root/.wine/drive_c/video/$script1")
$script2_wine = $("/root/.wine/drive_c/video/$script2")

(Get-Content 'deshake.template.pass1.avs') -replace '\[0\]', $path | Set-Content $script1_wine
(Get-Content 'deshake.template.pass2.avs') -replace '\[0\]', $path | Set-Content $script2_wine

$frameCount = ((Get-Content $log) -match '\d+')[1]

$scriptFullName1 = (Get-ChildItem $script1).FullName -replace '\\', '\\'
$scriptFullName2 = (Get-ChildItem $script2).FullName -replace '\\', '\\'
$out = $outFullName -replace '\\', '\\'

((Get-Content 'deshake.template.jobs') | Out-String) -f $scriptFullName1, $scriptFullName2, $out, $frameCount | Set-Content $('deshake.{0}.all.jobs' -f $name)
