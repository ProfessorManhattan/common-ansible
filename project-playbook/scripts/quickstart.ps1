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
$rebootrequired = 0

# @description Determines whether or not a reboot is pending
function Test-PendingReboot {
  if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return 1 }
  if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return 1 }
  if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return 1 }
  try {
    $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
    $status = $util.DetermineIfRebootPending()
    if (($status -ne $null) -and $status.RebootPending) {
      return 1
    }
  } catch {}
  return 0
}

# @description Ensure all Windows updates have been applied and then starts the provisioning process
function EnsureWindowsUpdated {
    Get-WUInstall -AcceptAll -IgnoreReboot
    $rebootrequired = Test-PendingReboot
    if ($rebootrequired -eq 1) {
        Restart-Computer -Wait
        $rebootrequired = 0
    }
}

# @description Ensures Microsoft-Windows-Subsystem-Linux feature is available
function EnsureLinuxSubsystemEnabled {
    $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
    if ($wslenabled.State -eq "Disabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
        $rebootrequired = 1
    }
}

# @description Ensure VirtualMachinePlatform feature is available
function EnsureVirtualMachinePlatformEnabled {
    $vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State
    if ($vmenabled.State -eq "Disabled") {
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
        $rebootrequired=1
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
workflow Provision-Windows-WSL-Ansible {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name PSWindowsUpdate -Force
    EnsureWindowsUpdated
    # Because of the error "A workflow cannot use recursion," we can just run the update process a few times to ensure everything is updated
    EnsureWindowsUpdated
    EnsureWindowsUpdated
    EnableWinRM
    EnsureLinuxSubsystemEnabled
    EnsureVirtualMachinePlatformEnabled
    if ($rebootrequired -eq 1) {
        Restart-Computer -Wait
    }
    EnsureUbuntuAPPXInstalled
    SetupUbuntuWSL
    EnsureDockerDesktopInstalled
    Restart-Computer -Wait
    RunPlaybook
}

# @description Run the PowerShell workflow job that spans across reboots
Provision-Windows-WSL-Ansible
