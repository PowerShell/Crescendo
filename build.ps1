[CmdletBinding(SupportsShouldProcess=$true)]
param ([switch]$test, [switch]$build, [switch]$publish, [switch]$sign)

$Name = "Microsoft.PowerShell.NativeCommandProxy"
$Lang = "en-US"
$ModRoot = "${PSScriptRoot}/${Name}"
$SrcRoot = "${ModRoot}/src"
$HelpRoot = "${ModRoot}/help/${Lang}"
$TstRoot = "${ModRoot}/test"
$SampleRoot = "${ModRoot}/Samples"
$ManifestPath = "${SrcRoot}/${Name}.psd1"
$ManifestData = Import-PowerShellDataFile -path $ManifestPath
$Version = $ManifestData.ModuleVersion
$PubRoot = "${PSScriptRoot}/out/${Name}"
$PubDir  = "${PubRoot}/${Version}"

if ( -not $test -and -not $build -and -not $publish -and -not $sign ) {
    throw "must use 'build', 'test', 'publish', or 'sign'"
}

[bool]$verboseValue = $PSBoundParameters['Verbose'].IsPresent ? $PSBoundParameters['Verbose'].ToBool() : $false

$FileManifest = @(
    @{ SRC = "${SampleRoot}/GetFileList.proxy.json"         ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/dd.proxy.json"                  ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/dockerRmImage.proxy.json"       ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/dockergetimage.proxy.json"      ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/dockergetps.proxy.json"         ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/dockerinspectimage.proxy.json"  ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/ifconfig.proxy.json"            ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/ls.proxy.json"                  ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/tar.proxy.json"                 ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}/who.proxy.json"                 ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${HelpRoot}/about_NativeCommandProxy.md"      ; DEST = "OUTDIR/help/${Lang}" }
    @{ SRC = "${SrcRoot}/${Name}.psm1"                      ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}/NativeCommandProxy.md"             ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}/${Name}.psd1"                      ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}/NativeProxyCommand.Schema.json"    ; DEST = "OUTDIR" }
)

if ($build) {
    Write-Verbose -Verbose -Message "No action for build"
}

if ($publish) {
    Write-Verbose "Publishing to '$PubDir'"
    if (-not (test-path $PubDir)) {
        $null = New-Item -ItemType Directory $PubDir -Force
    }
    foreach ($file in $FileManifest) {
        $src = $file.SRC
        $targetDir = $file.DEST -creplace "OUTDIR","$PubDir"
        if (-not (Test-Path $file.SRC)) {
            throw ("file '" + $file.SRC)
        }
        if (-not (Test-Path $targetDir)) {
            $null = New-Item -ItemType Directory $targetDir -Force
        }
        Copy-Item -Path $src -destination $targetDir
    }
}

if ($test) {

    Import-Module -force "${PSScriptRoot}/Microsoft.PowerShell.NativeCommandProxy/src/Microsoft.PowerShell.NativeCommandProxy.psd1"
    Push-Location "${PSScriptRoot}/Microsoft.PowerShell.NativeCommandProxy/test"
    try {
        $result = Invoke-Pester -PassThru
        if (0 -ne $result.FailedCount) {
            $result.testresult.Where({$_.result -eq "Failed"}).Foreach({Write-Error $_.Name})
            throw ("{0} failed tests" -f $result.FailedCount)
        }
    }
    finally {
        Pop-Location
    }
}

