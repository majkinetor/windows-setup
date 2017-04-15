<#
.SYNOPSIS
    Ensure git repositories are cloned.

.DESCRIPTION
    Ensures repositories given in the list exist locally. Repository can be
    specified as a string or hashtable with various options.
#>
function Ensure-GitRepositories {
    param(
        # Default clone path if $repo.path is not specified
        [string] $Root = "c:\Source",

        # Prefix to add if repository URI does not contain protocol
        [string] $Prefix = "https://github.com/",

        # List of repositories to clone, each element is string or hashtable.
        # Hashtable properties:
        #   uri   - Repository URI
        #   path  - Path to clone to
        #   depth - Git depth parameter
        #   force - Delete existing directory
        $Repos
    )

    log "|== Ensure Git Repositories"

    if (!(gcm git.exe -ea 0)) {throw 'Git not found on PATH'}

    git --version
    log "Clonning $($repos.Length) git repositories`n"
    $err=@()
    $ok=@()
    foreach ($repo in $Repos) {
        $r = @{}
        if ($repo -isnot [hashtable]) { $r.uri = $repo } else { $r = $repo }

        foreach( $protocol in 'http', 'https', 'git', 'ssh') {
            if ($r.uri.StartsWith($protocol+'://')) { $protocol = 'ok'; break }
        }
        if ($protocol -ne 'ok') { $r.uri = $Prefix + $r.uri}
        $repo_name = $r.uri -split '/' | select -Last 1

        if (!$r.path) {$r.path = $Root}
        $r.path = Join-Path $r.path $repo_name

        $cmd = "git clone"
        if ($r.depth) {$cmd += " --depth $($r.depth)"}
        $cmd += ' {0} {1}' -f $r.uri, $r.path
        log $cmd

        if ($r.force) { 
            log -fg yellow "Force enabled, existing directory will be deleted"
            rm $r.path -ea 0 -Recurse -Force
        }

        rm err -ea 0
        iex $cmd 2> err
        if (Test-Path err) { 
            $e = (gc err -Raw) -replace "(?ms)^At line.+?^\s*$" 
            $e = $e -split "`n" | ? { $_.Trim() } | ? { $_ -notlike "*git : Cloning into*"} | Out-String
            $e = $e.Trim()
            rm err -ea 0
        }
        if ($e) {log -fg red $e; $err += $r} else {$ok += $r}
        log
    }

    log
    log 'Success:', $ok.Length
    log 'Failed: ', $err.Length
    log
}