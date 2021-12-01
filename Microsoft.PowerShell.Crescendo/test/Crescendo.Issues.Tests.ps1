Describe "Fixes for various issues" {
	Context "Issue 54 - Don't show OriginalCommand in help example unless specified" {
		It "Example includes OriginalCommand" {
			$expectedResult = ".EXAMPLE","PS> get-thing","description","Original Command: originalCommand"
			$exampleInfo = New-ExampleInfo -command "get-thing" -description "description" -originalCommand "originalCommand"
			$observedResult = $exampleInfo.ToString().split([Environment]::newline).Where({$_})
			$observedResult | Should -BeExactly $expectedResult
		}

		It "Example omits OriginalCommand" {
			$expectedResult = ".EXAMPLE","PS> get-thing","description"
			$exampleInfo = New-ExampleInfo -command "get-thing" -description "description"
			$observedResult = $exampleInfo.ToString().split([Environment]::newline).Where({$_})
			$observedResult | Should -BeExactly $expectedResult
		}
	}
}