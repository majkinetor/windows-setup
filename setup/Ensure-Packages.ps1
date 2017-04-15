<#
.SYNOPSIS
    Ensure packages of given category are installed.

.DESCRIPTION
    Packages are kept in the ./packages folder in text files.
    Name format is `category.repo.txt`

.NOTES
    This is inteded to keep different repos such as npm, gem etc.
#>
function Ensure-Packages([string[]] $Categories='basic.choco')
{
    Write-Host "|== Ensure packages"
    
    if (!(Test-Path packages)) {
        'Packages directory not found.
         No package will be installed.' | Write-Warning; return
    }

    # TODO: Env vars in package lines
    $failures=@()
    $package_files = ls packages\* -Include ($Categories | % { $_ + '.txt' })
    foreach ($package_file in $package_files) {
        $packages = gc $package_file | ? { $_.Trim() }
        foreach ($package in $packages) { 
            $cmd = "choco install --limit-output -y $package"
            Write-Host $cmd
            $LastExitCode = 0
            $cmd | iex
            if ($LastExitCode) {
                $failures += $package
                Write-Warning "Failed to install: $package"
            }
            Update-SessionEnvironment | Out-Null
         }
    }

    Write-Host "`nINSTALLED PACKAGES:"
    choco.exe list -lo
    if ($failures.Length) {
        Write-Host ''
        Write-Warning "FAILED PACKAGES:"
        $failures| % Write-Warning
    }
    
    Write-Host ''
}