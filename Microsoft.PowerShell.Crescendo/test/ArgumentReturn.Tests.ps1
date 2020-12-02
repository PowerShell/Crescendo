$ArgProxyFile1 = "$PSScriptRoot/assets/ArgProxy.noParam1.json"
$ArgProxyFile2 = "$PSScriptRoot/assets/ArgProxy.noParam2.json"
$ArgProxyFile3 = "$PSScriptRoot/assets/ArgProxy.withParam.json"
Describe "Will return just argument array when configured" -tags CI {
    BeforeAll {
        $proxy1 = Import-CommandConfiguration $ArgProxyFile1
        $proxy2 = Import-CommandConfiguration $ArgProxyFile2
        $proxy3 = Import-CommandConfiguration $ArgProxyFile3
    }

    It "will return no arguments when no parameters are configured and no original elements" {
        invoke-expression $proxy1.ToString()
        $result = Invoke-ArgReturn
        $result | Should -BeNullOrEmpty
    }

    It "will return only non-parameter arguments when no parameters are configured and there are original elements" {
        invoke-expression $proxy2.ToString()
        $result = Invoke-ArgReturn
        $result | Should -Be @("--arg1","--arg2","--arg3")
    }

    It "will return arguments in the proper order when parameters are configured and there are original elements" {
        invoke-expression $proxy3.ToString()
        $result = Invoke-ArgReturn -Zap ThisIsZap -Zip ThisIsZip -Zup ThisIsZup
        $result | Should -Be @("--arg1","--arg2","--arg3","--zup","ThisIsZup","--zip","ThisIsZip","--zap","ThisIsZap")
    }


}
