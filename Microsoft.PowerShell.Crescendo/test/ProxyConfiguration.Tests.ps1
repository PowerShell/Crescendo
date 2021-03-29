Describe "Configuration based tests" -tags CI {
    BeforeAll {
        $proxyObject = Import-CommandConfiguration assets/SimpleProxy.json
    }
    It "Can create a simple proxy based on the mininum configuration" {
        $proxyObject | Should -Not -BeNullOrEmpty
    }
    It "Can correctly populate the properties of the proxy command" {
        $proxyObject.Verb | Should -Be Invoke
        $proxyObject.Noun | Should -Be "thing2"
        $proxyObject.OriginalName | Should -Be "/bin/app"
    }
}
