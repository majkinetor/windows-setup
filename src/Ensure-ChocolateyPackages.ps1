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

    Write-Host "|== Ensure Chocolatey Packages"
    
    if (!(Test-Path packages)) { throw 'Packages directory not found'  }

    $err=@()
    $ok=@()
    $package_files = ls packages\choco-*.txt -Include ($Categories | % { "choco-$_.txt" })
    foreach ($package_file in $package_files) {
        $packages = gc $package_file | ? { $_.Trim() } | ? { $_ -notlike '#*' }
        Write-Host "Ensuring $($packages.Length) packages:"
        foreach ($package in $packages) { 
            $cmd = "choco install --limit-output -y " + (expand $package)
            Write-Verbose $cmd
            $package_name = $package -split ' ' | select -first 1
            if (!$ShowDetails) { Write-Host -NoNewLine '  ' $package.PadRight(97) }
            
            # $LastExitCode return 1 on failure in console, but from script returns 0
            #  so I have to look into the log file
            rm $Env:ChocolateyInstall\logs\chocolatey.log -ea 0
            if ($ShowDetails) { $cmd | iex } else { $cmd | iex *> $null}
            $failed = (gc $Env:ChocolateyInstall\logs\chocolatey.log -Raw) -match '\[ERROR\] - Failures'

            $version = ((choco.exe list -le $package_name) -match $package_name) -split ' ' | select -Last 1
            if (!$version) {$version = 'N/A'}

            if ($failed) {
                $err += $package
                Write-Host -ForegroundColor red $version.PadRight(30) 'ERR'
                continue
            }
            $ok += $package
            Update-SessionEnvironment | Out-Null
            Write-Host -ForegroundColor yellow $version.PadRight(30) 'OK'
         }
    }

    if ($ShowDetails) {
        Write-Host "`nENSURED $($ok.Length) PACKAGES:"
        $ok | % { Write-Host -ForegroundColor yellow '  ' $_ }
        if ($err.Length) {
            Write-Host -ForegroundColor red "`nFAILED $($err.Length) PACKAGES:"
            $err | % { Write-Host -ForegroundColor red '  ' $_ }
        }
    }
    
    Write-Host ''
}