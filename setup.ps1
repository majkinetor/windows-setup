ls $PSScriptRoot\setup\*.ps1 | % { . $_ }
if (!(Test-Admin)) {throw "Administrastor privilegies are required"}

Ensure-Chocolatey
Ensure-Packages