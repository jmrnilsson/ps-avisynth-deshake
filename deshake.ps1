[CmdletBinding()]

Param
(
   [Parameter(Mandatory=$True,Position=1)]
   [string]$path
)

$name = ''
If (!$(Test-Path $path))
{
    Write-Error "'{0}' doesn't exist" -f $path
    exit 10
}
ElseIf ($(gci $path).PSIsContainer)
{
    Write-Error "Merge not supported at this time"
    exit 20
    $files = gci $path | ?{ !$_.PSIsContainer } | foreach { $_.FullName }
}
Else
{
    $name = $(gci $path).BaseName # | $_.Name
    $outDirectory = $(gci $path).Directory.FullName
    $output = gci $path | foreach { $_.BaseName + '.' + (get-date).ticks + $_.Extension }
    $outFullName = $($outDirectory + '\' + $output)

    Write-Output $('path={2}, name={0}, output={1}' -f $name, $output, $path)
}

$log = $('deshake.stats.{0}.log' -f $name)

If (!$(Test-Path $log))
{
    $script3 = $('deshake.framecount.{0}.avs' -f $name)
    $script0 = $('deshake.framecount.{0}.script' -f $name)

    ((Get-Content 'deshake.framecount.template.avs') | Out-String) -f $path, $($pwd.Path + '\' + $log) | Set-Content $script3
    ((Get-Content 'deshake.framecount.template.script') | Out-String) -f $($pwd.Path + '\' + $script3) -replace '\\', '\\' | Set-Content $script0
    $(.\virtualdub32\VirtualDub.exe /s $($pwd.Path + '\' + $script0))
    Write-Output 'Rerun job once frame counter completes..'
    Exit 69
}

$script1 = $('deshake.pass1.{0}.avs' -f $name)
$script2 = $('deshake.pass2.{0}.avs' -f $name)

(Get-Content 'deshake.pass1.template.avs') -replace '\[0\]', $path | Set-Content $script1
(Get-Content 'deshake.pass2.template.avs') -replace '\[0\]', $path | Set-Content $script2

$frameCount = ((Get-Content $log) -match '\d+')[1]

$scriptFullName1 = (gci $script1).FullName -replace '\\', '\\'
$scriptFullName2 = (gci $script2).FullName -replace '\\', '\\'
$out = $outFullName -replace '\\', '\\'

((Get-Content 'vdub.template.jobs') | Out-String) -f $scriptFullName1, $scriptFullName2, $out, $frameCount | Set-Content $('vdub.{0}.jobs' -f $name)
