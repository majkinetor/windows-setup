param(
    [string] $Password='monkey',
    [int] $RestartNo
)

ls $PSScriptRoot\src\*.ps1 | % { . $_ }
Init

#=======================================================================

stage 'Packages and tools' -Restart {
    Use-Chocolatey
    Use-ChocolateyPackages -Categories basic
    Use-GitRepositories -Root 'c:\Work'
}

stage 'Windows update' -Restart -Rerun  {
    if (Test-!Update) { log 'No updates available'; return }
    Update-Windows
}

stage 'Configure Windows' -Restart {
    Rename-Computer
    Set-ReginalSettings
    Set-Explorer
    Set-TaskBar
    Set-PinnedApps
    Set-Remoting
    Set-WindowsUpdate
}

stage 'Debloat Windows 10' -Restart { 
    $args = @{
        Path = c:\Source\Debloat-Windows-10\scripts\*.ps1
        Exclude = 'experimental_unfuckery.ps1'
    }
    ls @args | { . $_ }
}

Run-UserScripts
Restart-Windows -Mandatory -NoAutologon


if (!$RestartNo) {
    Ensure-Chocolatey
    #Ensure-ChocolateyPackages -Categories basic

    $repos = @(
        'majkinetor/powershell_profile.d'
        'majkinetor/posh'
        @{ uri='W4RH4WK/Debloat-Windows-10'; path='c:\Work\_'; depth=1 }
    )
    Ensure-GitRepositories -Root 'c:\Work' -Repos $repos
}
Restart-Windows -Reason 'Restart after tools installation'

1..2 | % { Restart-Windows -Reason "Dummy restart $_"}

"Windows setup done"