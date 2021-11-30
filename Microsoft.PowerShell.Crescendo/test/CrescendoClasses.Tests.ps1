Describe "The class tests" {

	Context "UsageInfo class" {
		It "New-Usage has a usage parameter with proper attributes" {
			$c = Get-Command -Name New-UsageInfo
			$p = $c.Parameters['usage']
			$p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"}).Position | Should -Be 0
			$p.ParameterType | Should -Be "string"
		}
		It "New-UsageInfo returns proper UsageInfo" {
			$ui = New-UsageInfo "This is usage"
			$ui.GetType() | Should -Be UsageInfo
		}
		It "ToString method returns correct data" {
			$ui = New-UsageInfo "This is usage"
			$observed = $ui.ToString()
			$expected = (Get-Content "${PSScriptRoot}/assets/UsageInfo1.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}
	}

	Context "ExampleInfo class" {
		BeforeAll {
			$c = Get-Command -Name New-ExampleInfo
		}

		It "New-ExampleInfo has a 'command' parameter with proper attributes" {
			$p = $c.Parameters['command']
			$pAttribute = $p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"})
			$pAttribute.Position | Should -Be 0
			$pAttribute.Mandatory | Should -Be $true
			$p.ParameterType | Should -Be "string"
		}

		It "New-ExampleInfo has a 'description' parameter with proper attributes" {
			$p = $c.Parameters['description']
			$pAttribute = $p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"})
			$pAttribute.Position | Should -Be 1
			$pAttribute.Mandatory | Should -Be $true
			$p.ParameterType | Should -Be "string"
		}

		It "New-ExampleInfo has a 'originalCommand' parameter with proper attributes" {
			$p = $c.Parameters['originalCommand']
			$pAttribute = $p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"})
			$pAttribute.Position | Should -Be 2
			$pAttribute.Mandatory | Should -Be $false
			$p.ParameterType | Should -Be "string"
		}

		It "New-ExampleInfo returns proper ExampleInfo" {
			$ei = New-ExampleInfo -command "this is a command" -description "This is a description"
			$ei.GetType() | Should -Be ExampleInfo
		}

		It "ToString method returns correct data" {
			$ei = New-ExampleInfo -command "this is a command" -description "This is a description"
			$observed = $ei.ToString()
			$expected = (Get-Content "${PSScriptRoot}/assets/ExampleInfo1.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}
	}

	Context "ParameterInfo class" {
		BeforeAll {
			$c = Get-Command -Name New-ParameterInfo
			$pi = New-ParameterInfo -Name P1 -OriginalName "--P1"
		}

		It "New-ParameterInfo has a 'Name' parameter with proper attributes" {
			$p = $c.Parameters['Name']
			$pAttribute = $p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"})
			$pAttribute.Position | Should -Be 0
			$pAttribute.Mandatory | Should -Be $true
			$p.ParameterType | Should -Be "string"
		}

		It "New-ParameterInfo has a 'OriginalName' parameter with proper attributes" {
			$p = $c.Parameters['OriginalName']
			$pAttribute = $p.Attributes.Where({$_.GetType().Name -eq "ParameterAttribute"})
			$pAttribute.Position | Should -Be 1
			$pAttribute.Mandatory | Should -Be $true
			$p.ParameterType | Should -Be "string"
		}

		It "New-ParameterInfo returns proper ParameterInfo" {
			$pi = New-ParameterInfo -Name name -OriginalName origName
			$pi.GetType() | Should -Be ParameterInfo
		}

		It "ParameterInfo has the '<Name>' property" -testCases @(
				@{ Name = "AdditionalParameterAttributes"; Type = "system.string[]" }
				@{ Name = "Aliases"; Type = "system.string[]" }
				@{ Name = "ApplyToExecutable"; Type = "system.boolean" }
				@{ Name = "DefaultMissingValue"; Type = "system.string" }
				@{ Name = "DefaultValue"; Type = "system.string" }
				@{ Name = "Description"; Type = "system.string" }
				@{ Name = "Mandatory"; Type = "system.boolean" }
				@{ Name = "Name"; Type = "system.string" }
				@{ Name = "NoGap"; Type = "system.boolean" }
				@{ Name = "OriginalName"; Type = "system.string" }
				@{ Name = "OriginalPosition"; Type = "system.int32" }
				@{ Name = "OriginalText"; Type = "system.string" }
				@{ Name = "ParameterSetName"; Type = "system.string[]" }
				@{ Name = "ParameterType"; Type = "system.string" }
				@{ Name = "Position"; Type = "system.int32" }
				@{ Name = "ValueFromPipeline"; Type = "system.boolean" }
				@{ Name = "ValueFromPipelineByPropertyName"; Type = "system.boolean" }
				@{ Name = "ValueFromRemainingArguments"; Type = "system.boolean" }
			) {
			param ($Name, $Type)
			$pi.psobject.properties["$Name"].TypeNameOfValue | Should -Be $Type
		}

		It "ToString method returns correct data for simple parameter" {
			$pi = New-ParameterInfo -Name Param1 -OriginalName "--param1"
			$observed = $pi.ToString()
			$expected = (Get-Content "${PSScriptRoot}/assets/ParameterInfo1.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}

		It "ToString method returns correct data for complex parameter with parameter set" {
			# note this is not a valid parameter
			$pi = New-ParameterInfo -Name Param1 -OriginalName "--param1="
			$pi.AdditionalParameterAttributes = "[ValidateRange(1,10)]","[ValidateNotNullOrEmpty()]"
			$pi.Aliases = "alias1","alias2"
			$pi.ApplyToExecutable = $true
			$pi.DefaultMissingValue = "defaultMissing"
			$pi.DefaultValue = "defaultValue"
			$pi.Description = "This is a description"
			$pi.Mandatory = $true
			$pi.NoGap = $true
			$pi.OriginalPosition = 10
			$pi.OriginalText = "originalText"
			$pi.ParameterSetName = "psetName"
			$pi.ParameterType = "int"
			$pi.Position = 0
			$pi.ValueFromPipeline = $true
			$pi.ValueFromPipelineByPropertyName = $true
			$pi.ValueFromRemainingArguments = $true
			$observed = $pi.ToString()
			$expected = (Get-Content "${PSScriptRoot}/assets/ParameterInfo2.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}

		It "ToString method returns correct data for complex parameter without parameter set" {
			# note this is not a valid parameter
			$pi = New-ParameterInfo -Name Param1 -OriginalName "--param1="
			$pi.AdditionalParameterAttributes = "[ValidateRange(1,10)]","[ValidateNotNullOrEmpty()]"
			$pi.Aliases = "alias1","alias2"
			$pi.ApplyToExecutable = $true
			$pi.DefaultMissingValue = "defaultMissing"
			$pi.DefaultValue = "defaultValue"
			$pi.Description = "This is a description"
			$pi.Mandatory = $true
			$pi.NoGap = $true
			$pi.OriginalPosition = 10
			$pi.OriginalText = "originalText"
			$pi.ParameterType = "int"
			$pi.Position = 0
			$pi.ValueFromPipeline = $true
			$pi.ValueFromPipelineByPropertyName = $true
			$pi.ValueFromRemainingArguments = $true
			$observed = $pi.ToString()
			$expected = (Get-Content "${PSScriptRoot}/assets/ParameterInfo3.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}

		It "returns an empty string if the parameter name is empty" {
			$pi = New-ParameterInfo -Name P1 -OriginalName "-p1"
			$pi.Name = ""
			$pi.ToString() | Should -BeNullOrEmpty
		}
	}

	Context "Command class" {
		It "GetCrescendoConfiguration method works correctly" {
			$c = New-CrescendoCommand -verb get -Noun thing
			$c.OriginalName = "doesnotexist"
			$c.Description = "A simple example"
			$c.Platform = "Windows"
			$c.Parameters.Add((New-ParameterInfo -Name p1 -OriginalName "--parameter1"))
			$c.GetCrescendoConfiguration()
			$c.Examples.Add((New-ExampleInfo -command "get-thing -p1 zapped" -description "An example"))
			$observed = $c.GetCrescendoConfiguration()
			$expected = (Get-Content "${PSScriptRoot}/assets/GetCrescendoConfiguration1.json") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}

		It "Properly creates a simple parameter map" {
			$cc = new-crescendocommand -verb get -noun thing
			$cp = New-ParameterInfo -Name P1 -OriginalName "-p1"
			$cp.DefaultMissingValue = "Default missing value"
			$cc.Parameters.Add($cp)
			$observed = $cc.GetParameterMap()
			$expected = (Get-Content "${PSScriptRoot}/assets/ParameterMap1.txt") -join [System.Environment]::newline
			$observed | Should -Be $expected
		}
	}

	Context "OutputHandler Class" {
		BeforeAll {
			$oh = New-OutputHandler
		}
		It "New-OutputHandler returns the proper type" {
			$oh.GetType().Name | Should -Be "OutputHandler"
		}

		It "Can create a proper output handler with property '<Name>'" -TestCases @(
			@{ Name = "ParameterSetName"; Type = "string" }
			@{ Name = "Handler"; Type = "string" }
			@{ Name = "HandlerType"; Type = "string" }
			@{ Name = "StreamOutput"; Type = "boolean" }
		) {
			param ($Name, $type )
			$oh.gettype().GetProperty("$Name").PropertyType.Name | Should -Be $type
		}

		It "A missing function output handler will cause an error" {
			$cc = New-CrescendoCommand -verb get -noun thing -original notavailable
			$oh = new-outputhandler
			$oh.HandlerType = "Function"
			$oh.Handler = "doesnotexist"
			$cc.OutputHandlers += $oh
			{ $cc.GetFunctionHandlers() } | Should -Throw -ErrorId "Cannot find function 'doesnotexist'."
		}
	}

	Context "CrescendoCommandInfo" {
		It "Exports a configuration properly" {
			$ci = New-CrescendoCommand -Verb Get -Noun Thing -OriginalName doesnotexist
			Export-CrescendoCommand -command $ci -TargetDirectory ${TESTDRIVE}
			$expected = (Get-Content "${PSScriptRoot}/assets/ExportCrescendoCommand1.json") -join [System.Environment]::NewLine
			$observed = (Get-Content "${TESTDRIVE}/Get-Thing.crescendo.json") -join [System.Environment]::NewLine
			$observed | Should -Be $expected
		}
	}

}