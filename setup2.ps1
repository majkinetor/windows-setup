<#
## Environment vars:

- $Env:AutologonPassword
- $Env:http_proxy

Must be saved and reaplied on restarts

## Stages

Serves as continuation and invocation mechanizm. If Windows is restarted it will continue on next stage. 
You can Restart-Windows in the middle of the stage or use -Restart argument for automatic check at
the end of the stage. If -Rerun argument is present, the current stage will continue and the only way 
to go to next stage is if there are no restarts.

You can also filter by stages: 
    setup.ps1 -Exclude 'Windows update', 'Debloat'
    setup.ps1 -Include 'Packages', 'Ruby'

- After restart - if -Restart is present - go to the next stage unless -Rerun is present 
  in which case rerun the same stage
- Do not restart if not pending by default unless -RestartAlways is present
- If there is no restart stage simply returns and goes to the next one, use return to exit anywhere
- If command is present outside of stage it will run before any stage ?!
- Stage can have restart limit either via -RestartLimit arg of globally via $Env:STAGE_RestartLimit
- Stage coculd have global env vars for all args: 
  Stage_Restart, Stage_RestartLimit, Stage_Rerun, State_RestartAlways

## Data

Contains deta for Use-*** functions in order to hide details. Function defines how it handles data.
it can be a file (data/chocolatey.txt) or folder (data/wallpapers/xyz.jpg) and it can be used for 
certain configs (prelude to hundreeth monkey tool) - data/totalcommander

Its probably best not to keep toools config here but basic OS stuff and package lists

## Bootstraper

- Timed script
- Retryable script
- Startup choices
- Logging
- Test-Admin
- 
#>

stage 'Packages and tools' -Restart {
    Install-Chocolatey [-Latest] [-Upgrade]
    Use-Packages -Type Choco
    Use-GitRepositories -Root 'c:\Work' -Repos  #take data/git.ps1        #hashtable
}

stage 'Ruby tools' {
    Install-Chocolatey [-Latest] [-Upgrade]
    Use-Packages -Type Chocolatey -Category ruby
    Use-Packages -Type Ruby -Category advanced
}

stage 'Windows update' -Restart -Rerun  {
    if (!(Test-Update)) { log 'No updates available'; return }
    Update-Windows
}

write-Host test     # This command is executed priro to all stages

stage 'Configure Windows' -Restart {
    Rename-Computer
    Set-ReginalSettings
    Set-Explorer
    Set-TaskBar
    Set-PinnedApps
    Set-Remoting
    Set-WindowsUpdate
    Set-WindowsTime -Update
    Set-UAC -Disable
    Set-InternetExplorer 
    Use-Wallpaper # data/wallpaper.jpg
}

stage 'Debloat Windows 10' -Restart { 
    $args = @{
        Path = c:\Source\Debloat-Windows-10\scripts\*.ps1
        Exclude = 'experimental_unfuckery.ps1'
    }
    ls @args | { . $_ }
}

stage 'Finalize' {
    Invoke-UserScripts      #In scripts folder
    Restart-Windows -Always -NoAutologon
}