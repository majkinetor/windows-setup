function Init {
    if (!(Test-Admin)) { throw "Administrastor privileges are required" }

    cd $PSScriptRoot\..
    
    if (!$RestartNo) { 
        log 'Removing old files'
        $null | Out-File setup.log
        $null | Out-File .restarts 
    }

    $script:results = @{}
    if ($RestartNo) { $msg = ", restarted $RestartNo times" }
    "`n", ("="*120), "`n" | Out-File -Append $PSScriptRoot\..\setup.log
    log "Windows setup started${msg}`n" 
}

function now() {
    (Get-Date).toString('s')
}

function log($msg='', $fgcolor='white', $bgcolor='', [switch]$nn, [int]$ident, [switch]$notime, [switch]$NoFile) {
    $params = @{
        Object = $(if ($notime) {} else { (now) + '   '} )  + ' '*$ident + $msg
        ForegroundColor = $fgcolor
        BackgroundColor = $bgcolor
    }
    if (!$bgcolor) { $params.Remove('BackgroundColor')}
    if (!$msg) { $params.object = ''}
    if ($nn) {$params.NoNewLine = $true}
    Write-Host @params
    if (!$NoFile) {
        $msg | Out-File -Append $PSScriptRoot\..\setup.log
    }
}
