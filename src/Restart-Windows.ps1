function Restart-Windows( [string]$Reason, [int]$Wait=5, [switch]$IfPending) {

    if (!$Reason) {
         Get-PSCallStack | % Location | select -Skip 1 | select -SkipLast 1 | set locations
         $Reason = $locations -join ' | '
         log 'Restart reason set automatically:',$Reason
    }

    $activated = (gc .restarts) -like "*. $Reason"
    if ($activated) { 
        log "Restart already activated: $Reason"
        return
    }

    $RestartNo += 1

    "$RestartNo. $Reason" | sc .restarts

    $args = @(
        gcm powershell | % Path
        Resolve-Path "$PSScriptRoot\..\setup.ps1"
        '-RestartNo ' + $RestartNo
    )
    $script = '{0} -NoExit -Command "& {1} {2}"' -f $args

    log "Restarting Windows with: ", $script
    if ($Wait) { 
        log "Waiting $Wait seconds before restarting " -nn
        1..$wait | % { log -nofile -nn -notime '.'; sleep 1} 
        log
    }

    Set-AutoLogon -LogonCount 1 -Username $Env:USERNAME -Password $Password -Script $script
    shutdown.exe /t 0 /r /f
}