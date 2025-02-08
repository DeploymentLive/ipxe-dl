function Invoke-SignTool {
    [cmdletbinding()]
    param(
        [string] $Path,
        [string] $Dest
    )

    #region Find openssl
    if ( -not ( get-command signtool.exe -ErrorAction SilentlyContinue ) ) { 
        $SignToolPath = (Get-ItemProperty -Path 'HKLM:\software\Microsoft\Windows Kits').KitsRoot10
        if ( -not (test-path $SignToolPath\bin\x64\openssl.exe )) { throw "Missing SignTool" }

        $env:path += ";$SignToolPath\bin\x64"

        ## Other places here

        if ( -not ( get-command openssl.exe ) ) { 
            throw "openssl.exe not found. Install Git for Windows" 
        }
    }
    #endregion     

    if ( (get-item Cert:\CurrentUser\my -CodeSigningCert | Measure).Count -ne 1 ) {
        throw "Can't find Code signing Cert."
    }

    Copy-Item @PSBoundParameters -force
    write-verbose "Sign /q /FD sha256 /v $Target" 
    SignTool.exe Sign /q /FD sha256 /v $Target

    ### XXX BUGBUG TODO - Will need to change this for production Signing 

}