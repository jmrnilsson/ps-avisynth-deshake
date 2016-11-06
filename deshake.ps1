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
    $output = gci $path | foreach { $_.BaseName + '.' +  ($(get-date -format s) -replace ':', '_') + '.AVI' }
    $outFullName = $($outDirectory + '\' + $output)

    Write-Output $('path={2}, name={0}, output={1}' -f $name, $output, $path)
}

$log = $('deshake.{0}.stats.log' -f $name)

If (!$(Test-Path $log))
{
    $script3 = $('deshake.{0}.framecount.avs' -f $name)
    $script0 = $('deshake.{0}.framecount.script' -f $name)

    ((Get-Content 'deshake.template.framecount.avs') | Out-String) -f $path, $($pwd.Path + '\' + $log) | Set-Content $script3
    ((Get-Content 'deshake.template.framecount.script') | Out-String) -f $($pwd.Path + '\' + $script3) -replace '\\', '\\' | Set-Content $script0
    $(.\virtualdub32\VirtualDub.exe /s $($pwd.Path + '\' + $script0))
    Write-Output 'Rerun job once frame counter completes..'
    Exit 69
}

$script1 = $('deshake.{0}.pass1.avs' -f $name)
$script2 = $('deshake.{0}.pass2.avs' -f $name)

(Get-Content 'deshake.template.pass1.avs') -replace '\[0\]', $path | Set-Content $script1
(Get-Content 'deshake.template.pass2.avs') -replace '\[0\]', $path | Set-Content $script2

$frameCount = ((Get-Content $log) -match '\d+')[1]

$scriptFullName1 = (gci $script1).FullName -replace '\\', '\\'
$scriptFullName2 = (gci $script2).FullName -replace '\\', '\\'
$out = $outFullName -replace '\\', '\\'

((Get-Content 'deshake.template.jobs') | Out-String) -f $scriptFullName1, $scriptFullName2, $out, $frameCount | Set-Content $('deshake_all.{0}.jobs' -f $name)
