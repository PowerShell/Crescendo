param ( [switch]$test, [switch]$build )

if ( $build ) {
    Write-Verbose -Verbose -Message "No action for build"
}

if ( $test ) {

    Import-Module -force "${PSScriptRoot}/Microsoft.PowerShell.NativeCommandProxy/src/Microsoft.PowerShell.NativeCommandProxy.psd1"
    Push-Location "${PSScriptRoot}/Microsoft.PowerShell.NativeCommandProxy/test"
    try {
        $result = Invoke-Pester -PassThru
        if ( 0 -ne $result.FailedCount ) {
            $result.testresult.Where({$_.result -eq "Failed"}).Foreach({Write-Error $_.Name})
            throw ("{0} failed tests" -f $result.FailedCount)
        }
    }
    finally {
        Pop-Location
    }
}

