# Configures an SSH server on our Windows host
# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse
# https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_server_configuration

function main {
    wsl -- sh -c 'wslpath -w $HOME' | cd
    install
    configure
    patch
    Write-Output 'Done'
}

function install {
    Write-Output 'Ensuring SSH server is installed'

    $sshServer = Get-WindowsCapability -Online | ? Name -like 'OpenSSH.Server*'
    if ($sshServer.State -ne 'Installed') {
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    }
}

function configure {
    Write-Output 'Starting SSH service'

    Start-Service sshd
    Set-Service -Name sshd -StartupType Automatic

    Write-Output 'Ensuring appropriate firewall rule exists'

    $firewallRule = Get-NetFirewallRule -Name "*ssh*"
    if (-not $firewallRule) {
        New-NetFirewallRule `
            -Name sshd `
            -DisplayName 'OpenSSH Server (sshd)' `
            -Enabled True `
            -Direction Inbound `
            -Protocol TCP `
            -Action Allow `
            -LocalPort 22
    }
}

function patch {
    Write-Output 'Updating sshd_config'

    cp .meta\windows\sshd_config C:\ProgramData\ssh\sshd_config
    Restart-Service sshd

    Write-Output 'Updating default shell to our WSL distro'

    # not sure how to pass any flags to wsl.exe here,
    # or the difference between using wsl.exe and bash.exe

    New-ItemProperty `
        -Path 'HKLM:\SOFTWARE\OpenSSH' `
        -Name DefaultShell `
        -Value 'C:\Windows\System32\wsl.exe' `
        -PropertyType String `
        -Force

    Write-Output "Copying authorized_keys to $HOME\.ssh"

    cp .config\ssh\authorized_keys "$HOME\.ssh\"
}

main
