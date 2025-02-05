function Compare-FilesIfNewer {
    <#
    .SYNOPSIS
        Compare to see if Source Files are Newer than Dest.
    .DESCRIPTION
        Use like a Make function to only return TRUE if the source files have a newer date (have changed).
    .EXAMPLE
        if ( Compare-FilesIfNewer -dest target.exe -sources @( source.c,source.res ) ) {
            cc -out target.exe source.c -r source.res
        }
    #>

    [CmdletBinding()]
    param (
        [string] $Dest,
        [string[]] $sources
    )

    if ( -not (test-path $dest) ) {
        write-verbose "If the $Dest does not exist, then force TRUE"
        return $true
    }

    $DestDate = (get-item $dest).LastWriteTime

    foreach ( $source in $Sources ) {
        if ( (get-Item $source).LastWriteTime -gt $DestDate ) {
            write-verbose "File is Newer: $Source"
            return $true
        }
    }

    write-verbose "All files are older"
    return $false
}