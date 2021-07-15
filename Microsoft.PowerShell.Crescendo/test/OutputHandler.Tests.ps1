Describe "Different types of output handlers are supported" {
	BeforeAll {
		$savedPath = $env:PATH
		$env:PATH = "$TESTDRIVE" + [System.IO.Path]::PathSeparator + $env:PATH
		# we have to put this in the global namespace, otherwise it will not be found
		function global:Convert-GetDate {
			[CmdletBinding()]
			param ([Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][DateTime]$date)
			PROCESS { "function:" + $date.date.ToString("MM/dd/yyyy") }
		}

'
[CmdletBinding()]
param ([Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][DateTime]$date)
PROCESS { "script:" + $date.date.ToString("MM/dd/yyyy") }
' > "$TESTDRIVE/Convert-GetDate.ps1"
			New-Item -ItemType Directory $TESTDRIVE/export
			Export-CrescendoModule -ModuleName $TESTDRIVE/export/multimodule -ConfigurationFile "$PSScriptRoot/assets/MultiHandler.json"
			Import-Module $TESTDRIVE/export/multimodule.psd1
	}	
	AfterAll {
		$env:PATH = $savedPath
		Remove-Module multimodule
	}

	It "inline output handler works correctly" {
		$result = Invoke-GetDate -ViaInline
		$result | Should -Match "^inline:"
	}

	It "function output handler works correctly" {
		$result = Invoke-GetDate -Viafunction
		$result | Should -Match "^function:"
	}

	It "script output handler works correctly" {
		$result = Invoke-GetDate -Viascript
		$result | Should -Match "^script:"
	}

}