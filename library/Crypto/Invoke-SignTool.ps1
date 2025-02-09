function Invoke-SignTool {
    [cmdletbinding()]
    param(
        [string] $Path,
        [string] $Dest
    )

    #region Find openssl
    if ( -not ( get-command signtool.exe -ErrorAction SilentlyContinue ) ) { 
        $SignToolPath = 'C:\Program Files (x86)\Windows Kits\10'
        if ( -not (test-path $SignToolPath\bin\x64\signtool.exe )) { throw "Missing SignTool" }

        $env:path += ";$SignToolPath\bin\x64"

        ## Other places here

        if ( -not ( get-command signtool.exe ) ) { 
            throw "signtool.exe not found. Install ADK/SDK for Windows" 
        }
    }
    #endregion     

    if ( (get-item Cert:\CurrentUser\my\* -CodeSigningCert | Measure).Count -ne 1 ) {
        throw "Can't find Code signing Cert."
    }

    Copy-Item @PSBoundParameters -force
    write-verbose "Sign /q /FD sha256 $Dest" 
    SignTool.exe Sign /q /a /FD sha256 $Dest

    ### XXX BUGBUG TODO - Will need to change this for production Signing 

}