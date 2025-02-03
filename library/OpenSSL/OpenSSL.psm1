
function Invoke-OpenSSL {
    <#
    .Synopsis
       Call OpenSSL
    .DESCRIPTION
       Invoke SSL command
    .EXAMPLE
       invoke-OpenSSL ( "x509 -in .\myfile.crt -text" -split ' ' )
    .NOTES
        If you pass in  "-passout", "env:keypass" into the command list
        the script will put the SecureString Argument into to the environment for use. 
    #>
    [CmdletBinding()]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=0)]
        [string[]] $Commands,
        [SecureString] $PassIn,
        [SecureString] $PassOut
    )

    #region Find openssl
    if ( -not ( get-command openssl.exe ) ) { 
        $GitPath = (Get-ItemProperty -Path HKLM:\SOFTWARE\GitForWindows).InstallPath
        if ( test-path $GitPath\usr\bin\openssl.exe ) {
            $env:path += ";$GitPath\usr\bin"
        }

        ## Other places here

        if ( -not ( get-command openssl.exe ) ) { 
            throw "openssl.exe not found. Install Git for Windows" 
        }
    }
    #endregion 

    #region Populate environment with passwords.

    $PassIn = $null 
    $passOut = $null
    for ( $i = 0; $i -le $commands.Length ; $i++ ) {
        if ( $commands[$i] -eq '-passin' -and $commands[$i+1].StartsWith('env:') ) { 
            write-verbose "PassIn: [$($commands[$i])] and [$($commands[$i+1])]"
            $PassIn = $commands[$i+1].Split(':')[1]
            set-item "env:$($PassIn)" -Value (New-Object PSCredential 0, $PassIn).GetNetworkCredential().Password
        }
        elseif ( $commands[$i] -eq '-passout' -and $commands[$i+1].StartsWith('env:') ) { 
            write-verbose "Passout: [$($commands[$i])] and [$($commands[$i+1])]"
            $passOut = $commands[$i+1].Split(':')[1]
            set-item "env:$($passOut)" -Value (New-Object PSCredential 0, $passOut).GetNetworkCredential().Password
        }        
    }

    #endregion

    # Invoke OpenSSL.exe
    write-verbose "OpenSSL.exe $($OpenSSLArgs -join ' ')"
    & OpenSSL.exe $OpenSSLArgs | write-verbose
    
    remove-item "env:$($PassIn)","env:$($passOut)" -ErrorAction SilentlyContinue

}