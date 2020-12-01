function New-StreamOutput {
    1..3 | foreach-object { [pscustomobject]@{ Value = $_; cTime = [datetime]::Now; oTime = [datetime]::new(0)}; Start-Sleep 2 }
}

$streamProxyFile = "$PSScriptRoot/assets/StreamProxy.json"
$bulkProxyFile = "$PSScriptRoot/assets/BulkProxy.json"

Describe "The framework respects the streamoutput setting (these tests take a while)" {
    BeforeAll {
        $streamProxy = Import-CommandConfiguration $streamProxyFile
        $bulkProxy = Import-CommandConfiguration $bulkProxyFile
    }
    It "will stream when the handler is set for streaming" {
        Invoke-Expression $streamProxy
        $r = Invoke-StreamProxy
        $durations = $r | foreach-object { $_.oTime - $_.cTime }
        $average = ($durations | measure-object -property totalmilliseconds -average ).Average
        $average | Should -BeLessThan 100 -Because "Average ($average) is greater than 100"
    }

    It "will bulk handle output when the handler is not set for streaming" {
        Invoke-Expression $bulkProxy
        $r = Invoke-StreamProxy
        $durations = $r | foreach-object { $_.oTime - $_.cTime }
        $average = ($durations | measure-object -property totalmilliseconds -average ).Average
        $average | Should -BeGreaterThan 2000 -Because "Average ($average) is less than 2000"

    }

    
}