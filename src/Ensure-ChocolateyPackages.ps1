<#
.SYNOPSIS
    Ensure Chocolatey packages of given category are installed.

.DESCRIPTION
    Packages are kept in the ./packages folder in text files.
    Name format is `choco-<category>.txt`

.NOTES
    This is inteded to keep different repos such as npm, gem etc.
#>
function Ensure-ChocolateyPackages {
    param(
        # List of package categories to install from the packages directory
        [string[]] $Categories='basic',

        # Show detailed console output
        [switch] $ShowDetails
    )

    log -fg blue "|== Ensure Chocolatey Packages"
    
    if (!(Test-Path packages)) { throw 'Packages directory not found'  }

    $err=@()
    $ok=@()
    $package_files = ls packages\choco-*.txt -Include ($Categories | % { "choco-$_.txt" })
    foreach ($package_file in $package_files) {
        $packages = gc $package_file | ? { $_.Trim() } | ? { $_ -notlike '#*' }
        log "Ensuring $($packages.Length) packages:"
        foreach ($package in $packages) { 
            $cmd = "choco install --limit-output -y " + (expand $package)
            Write-Verbose $cmd
            $package_name = $package -split ' ' | select -first 1
            if (!$ShowDetails) { log -nn -ident 2 $package.PadRight(97) }
            
            # $LastExitCode return 1 on failure in console, but from script returns 0
            #  so I have to look into the log file
            rm $Env:ChocolateyInstall\logs\chocolatey.log -ea 0
            if ($ShowDetails) { $cmd | iex } else { $cmd | iex *> $null}
            $failed = (gc $Env:ChocolateyInstall\logs\chocolatey.log -Raw) -match '\[ERROR\] - Failures'

            $version = ((choco.exe list -le $package_name) -match $package_name) -split ' ' | select -Last 1
            if (!$version) {$version = 'N/A'}

            if ($failed) {
                $err += $package
                log -fg red -notime $version.PadRight(30),'ERR'
                continue
            }
            $ok += $package
            Update-SessionEnvironment | Out-Null
            log -fg yellow -notime $version.PadRight(30),'OK'
         }
    }

    if ($ShowDetails) {
        log "`nENSURED $($ok.Length) PACKAGES:"
        $ok | % { log -fg yellow -ident 2 $_ }
        if ($err.Length) {
            log -fgcolor red "`nFAILED $($err.Length) PACKAGES:"
            $err | % { log -fgcolor red -ident 2 $_ }
        }
    }
    
    log
    log 'Success:', $ok.Length
    log 'Failed: ', $err.Length
    log ''
}