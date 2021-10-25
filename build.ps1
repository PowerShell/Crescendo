[CmdletBinding(SupportsShouldProcess=$true)]
param ([switch]$test, [switch]$build, [switch]$publish, [switch]$signed, [switch]$package)

$Name = "Microsoft.PowerShell.Crescendo"
$Lang = "en-US"
$ModRoot = "${PSScriptRoot}/${Name}"
$SrcRoot = "${ModRoot}/src"
$HelpRoot = "${ModRoot}/help/${Lang}"
$TestRoot = "${ModRoot}/test"
$SampleRoot = "${ModRoot}/Samples"
$ManifestPath = "${SrcRoot}/${Name}.psd1"
$ExpRoot = "${SrcRoot}/Experimental/HelpParsers"
$ManifestData = Import-PowerShellDataFile -path $ManifestPath
$Version = $ManifestData.ModuleVersion
$PubBase  = "${PSScriptRoot}/out"
$PubRoot  = "${PubBase}/${Name}"
$SignRoot = "${PSScriptRoot}/signed/${Name}"
$PubDir   = "${PubRoot}/${Version}"
$PubHelp  = "${PubDir}/${Lang}"

if (-not $test -and -not $build -and -not $publish -and -not $package) {
    throw "must use 'build', 'test', 'publish', 'package'"
}

[bool]$verboseValue = $PSBoundParameters['Verbose'].IsPresent ? $PSBoundParameters['Verbose'].ToBool() : $false

$FileManifest = @(
    @{ SRC = "${SampleRoot}"; NAME = "GetFileList.Crescendo.json"         ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dd.Crescendo.json"                  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockerRmImage.Crescendo.json"       ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockergetimage.Crescendo.json"      ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockergetps.Crescendo.json"         ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "dockerinspectimage.Crescendo.json"  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "ifconfig.Crescendo.json"            ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "ls.Crescendo.json"                  ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "tar.Crescendo.json"                 ; SIGN = $false ; DEST = "OUTDIR/Samples" }
    @{ SRC = "${SampleRoot}"; NAME = "who.Crescendo.json"                 ; SIGN = $false ; DEST = "OUTDIR/Samples" }

    @{ SRC = "${ExpRoot}";    NAME = "Convert-DockerHelp.ps1"             ; SIGN = $true  ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "Convert-KubectlHelp.ps1"            ; SIGN = $true  ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "Convert-NetshHelp.ps1"              ; SIGN = $true  ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "Convert-OpenFaasHelp.ps1"           ; SIGN = $true  ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "Convert-WingetHelp.ps1"             ; SIGN = $true  ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "README.md"                          ; SIGN = $false ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "HelpConversion002.gif"              ; SIGN = $false ; DEST = "OUTDIR/Experimental/HelpParsers" }
    @{ SRC = "${ExpRoot}";    NAME = "HelpConversion002.mp4"              ; SIGN = $false ; DEST = "OUTDIR/Experimental/HelpParsers" }

    @{ SRC = "${SrcRoot}";    NAME = "${Name}.Types.ps1xml"               ; SIGN = $true  ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "${Name}.Format.ps1xml"              ; SIGN = $true  ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "${Name}.psd1"                       ; SIGN = $true  ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "${Name}.psm1"                       ; SIGN = $true  ; DEST = "OUTDIR" }
    @{ SRC = "${SrcRoot}";    NAME = "Microsoft.PowerShell.Crescendo.Schema.json" ; SIGN = $false ; DEST = "OUTDIR" }
)

if ($build) {
    Write-Verbose -Verbose -Message "No action for build"
}

# this takes the files for the module and publishes them to a created, local repository
# so the nupkg can be used to publish to the PSGallery
function Export-Module
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
    param()
    if ( $signed ) {
        $packageRoot = $SignRoot
    }
    else {
        $packageRoot = $PubRoot
    }

    if ( -not (test-path $packageRoot)) {
        throw "'$PubDir' does not exist"
    }
    # now constuct a nupkg by registering a local repository and calling publish module
    $repoName = [guid]::newGuid().ToString("N")
    Register-PSRepository -Name $repoName -SourceLocation ${packageRoot} -InstallationPolicy Trusted
    Publish-Module -Path $packageRoot -Repository $repoName
    Unregister-PSRepository -Name $repoName
    Get-ChildItem -Recurse -Name $packageRoot | Write-Verbose
    $nupkgName = "{0}.{1}.nupkg" -f ${Name},${Version}
    $nupkgPath = Join-Path $packageRoot $nupkgName
    if ($env:TF_BUILD) {
        # In Azure DevOps
        Write-Host "##vso[artifact.upload containerfolder=$nupkgName;artifactname=$nupkgName;]$nupkgPath"
    }
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
    # Create about topic file
    $null = New-ExternalHelp -Output ${PubHelp} -Path "${HelpRoot}/about_Crescendo.md"
}

if ($package) {
    Export-Module
}

if ($test) {
    # be sure to not get pester 5
    if ( Get-Module Pester ) {
        Get-Module Pester | Where-Object { $_.Version -gt "4.9.9" } | Remove-Module
    }
    Import-Module -Force -Name Pester -MaximumVersion 4.99

    Import-Module -force "${PubRoot}"
    Push-Location "${TestRoot}"
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

