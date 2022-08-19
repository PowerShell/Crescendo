#
Describe "Multistage parameters behave properly" {
	It "creates parameters for both the executable and the command" {
        $helpers = & (get-module Microsoft.PowerShell.Crescendo){ Get-CrescendoNativeErrorHelper }
        Invoke-Expression ($helpers -join "`n")
		$config = Import-CommandConfiguration ${PSScriptRoot}/assets/MultiStageParameters.json
		Invoke-Expression ($config.ToString())
		$result = Invoke-Echo -exeParm1 ep1 -exeParm2 ep2 -cmdParm1 "cmd p2" -cmdParm2 cmd2  
		$expectedResult = '-exeParm1=ep1', '-exeParm2', 'ep2', # these are applied to the executable
				'element1', 'element2', # these are the original command elements
				'-cmdParm1="cmd p2"', '-cmdParm2', 'cmd2' # these are applied after the original command elements
		$result | Should -Be $expectedResult
	}
}
