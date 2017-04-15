ls $PSScriptRoot\src\*.ps1 | % { . $_ }

Start-Setup
Ensure-Chocolatey
Ensure-ChocolateyPackages
Ensure-GitRepositories -Root 'c:\Work' -Repos @(
    'majkinetor/powershell_profile.d'
    'majkinetor/posh'
    @{ uri='W4RH4WK/Debloat-Windows-10'; path='c:\Work\_'; depth=1; force=$true}
)

#Restart-Windows -RestartScript