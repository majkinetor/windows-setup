
<#
.SYNOPSIS
    Ensure chocolatey is available.

.DESCRIPTION
    Installs chocolatey in an idempotent way. 
    If behind the proxy, set `$env:http_proxy` environment variable.
#>
function Ensure-Chocolatey() {

    param(
        # Ensure latest version of chocolatey is present
        [switch] $Latest
    )

    log  "|== Ensure Chocolatey" -fg blue
    if ($env:http_proxy) { log "Using proxy: $env:http_proxy" } else { log "Not using proxy" }

    if (gcm choco.exe -ea 0) { 
        if ($Latest) { choco.exe upgrade chocolatey } 
        else { log 'Chocolatey version:', $(choco.exe --version) }
    } else {
        $env:chocolateyProxyLocation = $env:https_proxy = $env:http_proxy
        iwr https://chocolatey.org/install.ps1 -Proxy $http_proxy -UseBasicParsing | iex
    }

    . {
        choco feature enable -n=allowGlobalConfirmation
        choco feature enable -n=useRememberedArgumentsForUpgrades
    } *> $null

    # Ensure Update-SessionEnvironment is here before Chocolatye profile is set
    import-module -Scope Global C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1

    log
}