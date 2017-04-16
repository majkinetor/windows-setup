param(
    [string] $Password='monkey',
    [int] $RestartNo
)

ls $PSScriptRoot\src\*.ps1 | % { . $_ }
Init

#=======================================================================

if (!$RestartNo) {
    Ensure-Chocolatey
    Ensure-ChocolateyPackages -Categories test

    $repos = @(
        'majkinetor/powershell_profile.d'
        'majkinetor/posh'
        @{ uri='W4RH4WK/Debloat-Windows-10'; path='c:\Work\_'; depth=1 }
    )
    Ensure-GitRepositories -Root 'c:\Work' -Repos $repos
}

Restart-Windows -IfPending

"Windows setup done"