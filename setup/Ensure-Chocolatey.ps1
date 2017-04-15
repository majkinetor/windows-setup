
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
        [switch] $EnsureLatest
    )

    Write-Host "|== Ensure chocolatey"
    if ($env:http_proxy) { Write-Host "Using proxy: $env:http_proxy" } else { Write-Host "Not using proxy" }

    if (gcm choco.exe -ea 0) { 
        if ($EnsureLatest) { choco.exe upgrade chocolatey } 
        else { Write-Host 'Chocolatey version:' $(choco.exe --version) }
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

    Write-Host ''
}