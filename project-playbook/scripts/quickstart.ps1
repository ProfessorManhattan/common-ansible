#Requires -RunAsAdministrator

# @file scripts/quickstart.ps1
# @brief This script will help you easily take care of the requirements and then run [Gas Station](https://github.com/megabyte-labs/gas-station)
#   on your Windows computer.
# @description
#   1. This script will enable Windows features required for WSL.
#   2. It will reboot and continue where it left off.
#   3. Installs and pre-configures the WSL environment.
#   4. Ensures Docker Desktop is installed
#   5. Reboots and continues where it left off.
#   6. Ensures Windows WinRM is active so the Ubuntu WSL environment can provision the Windows host.
#   7. The playbook is run.

New-Item -ItemType Directory -Force -Path C:\Temp

# @description Ensure all Windows updates have been applied and then starts the provisioning process
function EnsureWindowsUpdated {
    Get-WUInstall -AcceptAll -IgnoreReboot
    if ((Test-PendingReboot).IsRebootPending) {
        Restart-Computer -Wait
    }
}

# @description Ensures Microsoft-Windows-Subsystem-Linux feature is available
function EnsureLinuxSubsystemEnabled {
    $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
    if ($wslenabled.State -eq "Disabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    }
}

# @description Ensure VirtualMachinePlatform feature is available
function EnsureVirtualMachinePlatformEnabled {
    $vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State
    if ($vmenabled.State -eq "Disabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    }
}

# @description Ensures Ubuntu 20.04 is installed on the system from a .appx file
function EnsureUbuntuAPPXInstalled {
    if(!(Test-Path "C:\Temp\UBUNTU2004.appx")) {
        Start-BitsTransfer -Source "https://aka.ms/wslubuntu2004" -Destination "C:\Temp\UBUNTU2004.appx" -Description "Downloading Ubuntu 20.04 WSL image"
    }
    $ubu2004appxinstalled = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu20.04onWindows
    if (!$ubu2004appxinstalled) {
        Add-AppxPackage -Path "C:\Temp\UBUNTU2004.appx"
    }
}

# @description Automates the process of setting up the Ubuntu 20.04 WSL environment
function SetupUbuntuWSL {
    Start-Process "ubuntu.exe" -ArgumentList "install --root" -Wait -NoNewWindow
    $username = $env:username
    Start-Process "ubuntu.exe" -ArgumentList "run adduser $username --gecos 'First,Last,RoomNumber,WorkPhone,HomePhone' --disabled-password" -Wait -NoNewWindow
    Start-Process "ubuntu.exe" -ArgumentList "run usermod -aG sudo $username" -Wait -NoNewWindow
    Start-Process "ubuntu.exe" -ArgumentList "run echo '$username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" -Wait -NoNewWindow
    Start-Process "ubuntu.exe" -ArgumentList "config --default-user $username" -Wait -NoNewWindow
}

# @description Ensures Docker Desktop is installed (which requires a reboot)
function EnsureDockerDesktopInstalled {
    if (!(Test-Path "C:\Temp\docker-desktop-installer.exe")) {
        Start-BitsTransfer -Source "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe" -Destination "C:\Temp\docker-desktop-installer.exe" -Description "Downloading Docker Desktop"
    }
    Start-Process 'C:\Temp\docker-desktop-installer.exe' -ArgumentList 'install --quiet' -Wait -NoNewWindow
    & 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    Start-Sleep -s 30
}

# @description Enables WinRM connectivity
function EnableWinRM {
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file -Verbose -EnableCredSSP -DisableBasicAuth -SkipNetworkProfileCheck
}

# @description Run the playbook
function RunPlaybook {
    Start-Process "ubuntu.exe" -ArgumentList "run curl -sSL https://gitlab.com/megabyte-labs/gas-station/-/raw/master/scripts/quickstart.sh > quickstart.sh && bash quickstart.sh" -Wait -NoNewWindow
    Start-Process "ubuntu.exe" -ArgumentList "run bash ~/Playbooks/.cache/ansible-playbook-continue-command.sh" -Wait -NoNewWindow
}

# @description The main logic for the script - enable Windows features, set up Ubuntu WSL, and install Docker Desktop
# while continuing script after a restart.
workflow ProvisionWindowsWSLAnsible {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Force
    Install-Module -Name PendingReboot
    EnsureWindowsUpdated
    # Because of the error "A workflow cannot use recursion," we can just run the update process a few times to ensure everything is updated
    EnsureWindowsUpdated
    EnsureWindowsUpdated
    EnableWinRM
    EnsureLinuxSubsystemEnabled
    EnsureVirtualMachinePlatformEnabled
    if ((Test-PendingReboot).IsRebootPending) {
        Restart-Computer -Wait
    }
    EnsureUbuntuAPPXInstalled
    SetupUbuntuWSL
    EnsureDockerDesktopInstalled
    Restart-Computer -Wait
    RunPlaybook
}


$options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
$secpasswd = ConvertTo-SecureString "Aa123456!" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("WELCOME\Administrator", $secpasswd)
$AtStartup = New-JobTrigger -AtStartup

# Source: https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
Register-ScheduledJob -Name ProvisionWindowsWSLAnsibleJob -Trigger $AtStartup -ScriptBlock ({[System.Management.Automation.Remoting.PSSessionConfigurationData]::IsServerManager = $true; Import-Module PSWorkflow; Resume-Job -Name RebootContinueWorkflow -Wait}) -ScheduledJobOption $options
ProvisionWindowsWSLAnsible -AsJob -JobName RebootContinueWorkflow
