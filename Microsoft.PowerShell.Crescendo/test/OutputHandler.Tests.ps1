using namespace System.Management.Automation.Language

Describe "Different types of output handlers are supported" {
	BeforeAll {
		$savedPath = $env:PATH
		$env:PATH = "$TESTDRIVE" + [System.IO.Path]::PathSeparator + $env:PATH

'
[CmdletBinding()]
param ([Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][DateTime]$date)
PROCESS { "script:" + $date.date.ToString("MM/dd/yyyy") }
' > "$TESTDRIVE/Convert-GetDate.ps1"

        New-Item -ItemType Directory $TESTDRIVE/export

        InModuleScope Microsoft.PowerShell.Crescendo {
            # we have to put this in the global namespace, otherwise it will not be found
            function Convert-GetDateFunction {
                [CmdletBinding()]
                param ([Parameter(ValueFromPipeline=$true,Position=0,Mandatory=$true)][DateTime]$date)
                PROCESS { "function:" + $date.date.ToString("MM/dd/yyyy") }
            }
            Export-CrescendoModule -ModuleName $TESTDRIVE/export/multimodule -ConfigurationFile "$PSScriptRoot/assets/MultiHandler.json"
        }

        Import-Module $TESTDRIVE/export/multimodule.psd1
	}	
	AfterAll {
		$env:PATH = $savedPath
		Remove-Module multimodule -ErrorAction SilentlyContinue
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

    It "The function declaration should be in the module only once" {
        $moduleInfo = Get-Module multimodule
        $ast = [Parser]::ParseFile($moduleInfo.Path, [ref]$null, [ref]$null)
        $functionAst = $ast.FindAll({$args[0] -is [FunctionDefinitionAst] -and $args.Name -eq "Convert-GetDateFunction"}, $true)
        $functionAst.Count | Should -Be 1
    }

    It "will produce an error if the output hander function is not available" {
        $configuration = Join-Path -Path $PSScriptRoot -ChildPath assets -AdditionalChildPath HandlerFault4.json
        { Export-CrescendoModule -ModuleName "$TESTDRIVE/badmod" -Configur $configuration } | 
            Should -Throw -ErrorId "Cannot find output handler function 'ThisFunctionHandlerDoesNotExist'."
    }

    It "will handle an output handler of type 'Bypass'" {
        Invoke-GetDate2 | Should -BeOfType [DateTime]
    }

}
