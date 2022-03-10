Describe "Can handle default values correctly" {
	BeforeAll {
		$configuration = Import-CommandConfiguration -file "$PSScriptRoot/assets/DefaultValues.json"
		Invoke-Expression ($configuration.ToString())
	}

	It "Default values are present when no parameters are provided" {
		$result = Invoke-Echo
		$expectedResults = @(
			"--par1"
			"defval1"
			"--par2"
			"defval2"
		)
		$result.count | Should be $expectedResults.Count
		$result | Should -Be $expectedResults
	}

	It "overriding default value for parameter 1 does not override parameter 2" {
		$result = Invoke-Echo -Parameter1 val1
		$expectedResults = @(
			"--par1"
			"val1"
			"--par2"
			"defval2"
		)
		$result | Should -Be $expectedResults
	}

	It "overriding default value for parameter 2 does not override parameter 1" {
		$result = Invoke-Echo -Parameter2 val2
		$expectedResults = @(
			"--par1"
			"defval1"
			"--par2"
			"val2"
		)
		$result | Should -Be $expectedResults
	}

	It "overriding all default values" {
		$result = Invoke-Echo -Parameter1 val1 -Parameter2 val2
		$expectedResults = @(
			"--par1"
			"val1"
			"--par2"
			"val2"
		)
		$result | Should -Be $expectedResults
	}

	It "providing 3rd value does not hinder default values" {
		$result = Invoke-Echo -Parameter3 val3
		$expectedResults = @(
			"--par1"
			"defval1"
			"--par2"
			"defval2"
			"--par3"
			"val3"
		)
		$result | Should -Be $expectedResults
	}

	It "overriding a value and providing 3rd value does not hinder default value" {
		$result = Invoke-Echo -Parameter1 val1 -Parameter3 val3
		$expectedResults = @(
			"--par1"
			"val1"
			"--par2"
			"defval2"
			"--par3"
			"val3"
		)
		$result | Should -Be $expectedResults
	}

}