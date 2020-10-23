[CmdletBinding(SupportsShouldProcess=$true)]
param ([switch]$test, [switch]$build, [switch]$publish, [switch]$signed)

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
$PubBase  = "${PSScriptRoot}/out"
$PubRoot  = "${PubBase}/${Name}"
$SignRoot = "${PSScriptRoot}/signed"
$PubDir   = "${PubRoot}/${Version}"

if (-not $test -and -not $build -and -not $publish) {
    throw "must use 'build', 'test', 'publish'"
}

[bool]$verboseValue = $PSBoundParameters['Verbose'].IsPresent ? $PSBoundParameters['Verbose'].ToBool() : $false

$FileManifest = @(
    @{ SRC = "${SampleRoot}"; NAME = "GetFileList.proxy.json"         ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dd.proxy.json"                  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockerRmImage.proxy.json"       ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockergetimage.proxy.json"      ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockergetps.proxy.json"         ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockerinspectimage.proxy.json"  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "ifconfig.proxy.json"            ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "ls.proxy.json"                  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "tar.proxy.json"                 ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "who.proxy.json"                 ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${HelpRoot}";   NAME = "about_NativeCommandProxy.md"    ; SIGN = $false ; DEST = "OUTDIR/help/${Lang}" }
    @{ SRC = "${SrcRoot}";    NAME = "${Name}.psm1"                   ; SIGN = $false ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "NativeCommandProxy.md"          ; SIGN = $false ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "${Name}.psd1"                   ; SIGN = $false ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "NativeProxyCommand.Schema.json" ; SIGN = $false ; DEST = "OUTDIR" }
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
        if ($signed -and $file.SIGN) {
            $src = Join-Path -Path $PSScriptRoot -AdditionalChildPath $file.NAME -ChildPath signed
        }
        else {
            $src = Join-Path -Path $file.SRC -ChildPath $file.NAME
        }
        $targetDir = $file.DEST -creplace "OUTDIR","$PubDir"
        if (-not (Test-Path $src)) {
            throw ("file '" + $src + "' not found")
        }
        if (-not (Test-Path $targetDir)) {
            $null = New-Item -ItemType Directory $targetDir -Force
        }
        Copy-Item -Path $src -destination $targetDir -Verbose:$verboseValue
    }
    # now constuct a nupkg by registering a local repository and calling publish module
    $repoName = [guid]::newGuid().ToString("N")
    Register-PSRepository -Name $repoName -SourceLocation ${PubBase} -InstallationPolicy Trusted
    Publish-Module -Path $PubDir -Repository $repoName
    Unregister-PSRepository -Name $repoName
    Get-ChildItem $PubBase | Out-String
    $nupkgName = "{0}.{1}.nupkg" -f ${Name},${Version}
    $nupkgPath = Join-Path $PubBase $nupkgName
    if ($env:TF_BUILD) {
        # In Azure DevOps
        Write-Host "##vso[artifact.upload containerfolder=$nupkgName;artifactname=$nupkgName;]$nupkgPath"
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

