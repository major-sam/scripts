<#.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER Height
    Terminal window height .
.PARAMETER Width
    Terminal window width .
.PARAMETER Machines
    Specifies a list machine for connect to.
.EXAMPLE
    C:\PS> powershell -f .\runRemoteDesktop.ps1 -width 1366 -height 768 -machines vm-n2-ws5, vm-n2-ws4
    Run 2 terminal connection in 1366x768 frame
.NOTES
    Author: vrebiachikh
    Date:   18.08.2021    
#>
#USAGE powershell -f .\runRemoteDesktop.ps1 -width 1366 -height 768 -machines vm-n2-ws5, vm-n2-ws4
#
param(
    
    [Parameter(HelpMessage='Введите высоту окна')]
        $Height =768,
        
    [Parameter(HelpMessage='Введите ширину окна')]
        $Width = 1024,
        
    [Parameter(Mandatory,HelpMessage='Введите список терминалов через запятую')]
        $Machines
 )

foreach($machine in $machines){

    mstsc /h:$height /w:$width /v:$machine
}