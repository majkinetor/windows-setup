function Start-Setup {
    if (!(Test-Admin)) {throw "Administrastor privilegies are required"}
    
    $script:results = @{}
    Write-Host "Windows setup started at $(now)"
}

function now() {
    (Get-Date).toString('s')
}

function log($msg='', $fgcolor='white', $bgcolor='black', [switch]$nn, [int]$ident) {
    $params = @{
        Object = ' '*$ident + $msg
        ForegroundColor = $fgcolor
        BackgroundColor = $bgcolor
    }
    if ($nn) {$params.NoNewLine = $true}
    Write-Host @params
}
