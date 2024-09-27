Describe "Export-CrescendoCommand tests" {
	BeforeAll {
		$assetDir = Join-Path -Path $PSScriptRoot -ChildPath "../Samples"
		$configurationSet = Get-ChildItem -Path $assetDir -Filter "Docker*" |
			ForEach-Object { $_.FullName } |
			Sort-Object
		$commands = $configurationSet | ForEach-Object { Import-CommandConfiguration $_ }
		$commandNames = $commands.FunctionName | Sort-Object
		$expectedFilenames = $commandNames.foreach({"${_}.crescendo.json"})
		$singleCommand = $commands[0]
	}

	Context "MultipleFile parameter set" {
		BeforeAll {
			Export-CrescendoCommand -Command $commands -targetDirectory TestDrive:
			$expectedCount = $expectedFilenames.Count
			$testCases = $expectedFilenames | Foreach-Object {
				@{ file = $_ }
			}
		}

		It "Correct count of files should be present" {
			(Get-ChildItem TestDrive:).Count | Should -Be $expectedCount
		}

		It "individual file '<file>' exists" -testCases $testCases {
			param ( $file )
			$filePath = Join-Path -Path TestDrive: -ChildPath $file
			$filePath |  Should -Exist
		}

        It "The exported file should be able to be imported" -testCases $testCases {
            param ( $file )
            $filePath = Join-Path -Path TestDrive: -ChildPath $file
            $modName = $file -replace ".json", "_module"
            Export-CrescendoModule -ModuleName "${testdrive}/${modName}" -ConfigurationFile $filePath -Force
        }

        # check for proper case of commands element
        It "The exported file '<file>' should have the proper 'Commands' element" -testcases $testCases {
            param ($file)
            $obj = Get-Content (Join-Path $testdrive $file) | ConvertFrom-Json
            $obj.PSObject.Properties.Where({$_.Name -eq "commands"}).Name | Should -BeExactly "Commands"
        }
	}

	Context "SingleFile parameter set" {
		BeforeAll {
			$comboCrescendoFile = "TestDrive:combo.crescendo.json"
			Export-CrescendoCommand -Command $commands -filename $comboCrescendoFile
			$comboJson = Get-Content $comboCrescendoFile | ConvertFrom-Json
			$comboCommandNames = $comboJson.Commands.Foreach({"{0}-{1}" -f $_.Verb, $_.Noun})
			$testCases = $comboCommandNames.Foreach({@{ file = $_ }})

			$singleCrescendoFile = "TestDrive:single.crescendo.json"
			Export-CrescendoCommand -Command $singleCommand -filename $singleCrescendoFile
			$singleJson = Get-Content $singleCrescendoFile | ConvertFrom-Json
			$singleCommandName = $singleCommand.FunctionName
		}

		It "file 'TestDrive:combo.crescendo.json' should exist" {
			Get-Item $comboCrescendoFile | Should -Exist
		}

		It "The file should have the correct count of commands" {
			$comboJson.Commands.Count | Should -Be $expectedCount
		}

		It "The command '<file>' is found in the configuration" -TestCases $testCases {
			param ( $file )
			$file | Should -BeIn $comboCommandNames
		}

		It "Single file configuration should exist" {
			Get-Item $singleCrescendoFile | Should -Exist
		}

		It "The single file configuration should have the correct count of commands" {
			$singleJson.Commands.Count | Should -Be 1
		}

		It "The single file configuration should have the correct command" {
			$cmdName = $singleJson.Commands[0].Verb + "-" + $singleJson.Commands[0].Noun
			$cmdName | Should -Be $singleCommandName
		}

		It "If the file exists, an error should be thrown" {
			{ Export-CrescendoCommand -Command $commands -filename $comboCrescendoFile } |
				Should -Throw "File '$comboCrescendoFile' already exists"
		}

		It "Force should overwrite the file without error" {
			Export-CrescendoCommand -Command $commands[0,1] -filename $comboCrescendoFile -Force
			$comboCrescendoFile | Should -Exist
			$json = Get-Content $comboCrescendoFile | ConvertFrom-Json
			$json.Commands.Count | Should -Be 2
		}

		It "WhatIf should not create a file" {
			$whatifFile = "TestDrive:whatif.crescendo.json"
			$cmd = New-CrescendoCommand -Noun Get -Verb Thing -OriginalName notexist
			Export-CrescendoCommand -Command $cmd -filename $whatifFile -WhatIf
			$whatifFile | Should -Not -Exist
		}

	}


}
