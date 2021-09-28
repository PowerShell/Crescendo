Describe "Ensure that the cmdlet attribute is created correctly" {
	BeforeAll {
		function Get-ConfirmImpactSetting {
			param ( $name )
			$function = Get-Item "function:${name}"
			$function.ScriptBlock.Attributes.ConfirmImpact
		}
	}
	Context "Object model tests for ConfirmImpact" {
		BeforeAll {
			$testcases = @{ Level = "High"; Verb = "get"; Noun = "thing1" },
				@{ Level = "Medium"; Verb = "get"; Noun = "thing2" },
				@{ Level = "Low"; Verb = "get"; Noun = "thing3" },
				@{ Level = "None"; Verb = "get"; Noun = "thing4" }
		}

		It "Can set the ConfirmImpact level to '<Level>'" -TestCases $testcases {
			param ($Level, $Verb, $Noun)
			$c = New-CrescendoCommand -Verb $verb -Noun $Noun -OriginalName "nofile"
			$c.SupportsShouldProcess = $true
			$c.ConfirmImpact = $Level
			Invoke-Expression ($c.ToString())
			$confirmImpactSetting = Get-ConfirmImpactSetting ("${Verb}-${Noun}")
			$confirmImpactSetting | Should -Be $Level
			Remove-Item "function:${Verb}-${Noun}"
		}

		It "Setting ConfirmImpact to an invalid value will result in an error" {
			$c = New-CrescendoCommand -Verb Get -Noun Thing5 -OriginalName "nofile"
			$c.SupportsShouldProcess = $true
			$c.ConfirmImpact = "Zipper"
			{ $c.ToString() } | Should -Throw
		}

	}
	Context "Object model tests for ConfirmImpact" {
		BeforeAll {
			$testcases = @{ Setting = "High"; Expected = "High"; Command = "get-thing1" },
				@{ Setting = "Medium"; Expected = "Medium"; Command = "get-thing2" },
				@{ Setting = "Low"; Expected = "Low"; Command = "get-thing3" },
				@{ Setting = "None"; Expected = "None"; Command = "get-thing4" },
				@{ Setting = ""; Expected = "Medium"; Command = "get-thing5" } # not explicitely set
			$cmds = Import-CommandConfiguration $PSScriptRoot/assets/SetConfirmImpact.json
			$cmds.Foreach({Invoke-Expression ($_.ToString())})
		}

		It "Setting ConfirmImpact to '<Setting>' in configuration is correct" -TestCases $testcases {
			param ( $Setting, $Expected, $command )
			$observed = Get-ConfirmImpactSetting $command
			$observed | Should -Be $Expected
		}
	}
}