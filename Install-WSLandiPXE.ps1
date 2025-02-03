#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Script to install and configure WSL on Windows Host
.DESCRIPTION
    Install and Prepare machine for Windows Services for Linux
.NOTES
    May need to be executed more than once due to reboots. 
.LINK
    https://github.com/DeploymentLive/ipxe
#>

[CmdletBinding()]
param (
    $Distro = 'ubuntu',
    $ipxe = 'https://github.com/ipxe/ipxe.git',
    $DeploymentLiveiPXE = 'https://github.com/DeploymentLive/ipxe-dl.git'
)

# https://stackoverflow.com/questions/66127118/why-cannot-i-match-for-strings-from-wsl-exe-output
$env:WSL_UTF8=1 

#region Step 1 Ensure WSL Feature is installed

$state = (Get-WindowsOptionalFeature -online -FeatureName Microsoft-Windows-Subsystem-Linux).State

if ( $state -ne [Microsoft.Dism.Commands.FeatureState]::Enabled ) {
    write-verbose "Enable Optional Feature Microsoft-Windows-Subsystem-Linux (May require RESTART)"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

if ( -not ( get-command wsl.exe -ErrorAction SilentlyContinue )) { throw "bad build of Windows no wsl.exe"}

#endregion

#region Step 2 Install Linux Distro 

wsl.exe --status | Write-Verbose
# wsl.exe --version | Write-Verbose

wsl.exe --list  | Write-Verbose
if ( $LASTEXITCODE -eq -1 ) {
    write-verbose "install Linux Distro Ubuntu" 
    wsl.exe --install -d $Distro  --web-download
    echo "launch Ubuntu terminal window and create your default user account."
    Read-Host -Prompt "Press enter to continue"
}

#endregion

#region Step 3 Update everything

write-verbose "Update manifest"
wsl.exe -u root -- apt-get -y update
# wsl.exe -u root -- apt-get -y full-upgrade

#endregion

#region Step 4 Install required tools through apt

if (!((wsl -- apt list --installed gcc ) -match 'gcc' )) {

    write-verbose "Install Required Components"

    # From: https://ipxe.org/download
    $Packages = @"
gcc
gcc-aarch64-linux-gnu
gcc-arm-linux-gnueabi
binutils
binutils-arm-linux-gnueabi
make
perl
liblzma-dev
mtools
mkisofs
syslinux
"@ -split "`r`n"

    foreach ( $Package in $Packages ) {

        write-verbose "Install $Package"
        wsl.exe -u root -- apt install -y $Package
    }

}

#endregion

#region Step 5 Upgrade everything

write-verbose "Full Upgrade"
wsl.exe -u root -- apt-get -y full-upgrade

#endregion

#region Step 6 clone or update git repo

wsl -- ls ~/ipxe/src/include
if ( $LASTEXITCODE -eq 2 ) {
    write-verbose "clone repo $ipxe"
    wsl --cd ~ git clone $ipxe 
}
else {
    write-verbose "update repo"
    wsl -- cd ~/ipxe ';' git pull origin master
}

wsl -- ls ~/ipxe-dl/readme.md
if ( $LASTEXITCODE -eq 2 ) {
    write-verbose "clone repo $DeploymentLiveiPXE"
    wsl --cd ~ git clone $DeploymentLiveiPXE
}
else {
    write-verbose "update repo"
    wsl -- cd ~/ipxe-dl ';' git pull origin master
}


# Create Symbolic Links for config/local/*

foreach ( $name in get-item $PSscriptRoot\config\* | Foreach-item Name ) {

    wsl -- ls ~/ipxe/src/config/local/$name
    if ( $LASTEXITCODE -eq 2 ) {
        write-verbose "Create a SymLink to our local config settings $name"
        wsl -- ln -s ~/ipxe-dl/config/$name ~/ipxe/src/config/local/$name
    }
}
#endregion
