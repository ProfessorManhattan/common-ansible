#Requires -RunAsAdministrator

# @file scripts/quickstart.ps1
# @brief This script will help you easily take care of the requirements and then run [Gas Station](https://github.com/megabyte-labs/gas-station)
#   on your Windows computer.
# @description
#   1. This script will enable Windows features required for WSL.
#   2. It will reboot and continue where it left off.
#   3. Ensures Windows WinRM is active so the Ubuntu WSL environment can provision the Windows host.
#   4. Installs and pre-configures the WSL environment.
#   5. Ensures Docker Desktop is installed
#   6. Reboots and continues where it left off.
#   7. The playbook is run.

$quickstartScript = "C:\Temp\quickstart.ps1"

New-Item -ItemType Directory -Force -Path C:\Temp
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# @description Reboot and continue script after reboot
function RebootAndContinue {
  if (!(Test-Path $quickstartScript)) {
    Write-Host "Ensuring the recursive update script is downloaded"
    Start-BitsTransfer -Source "https://install.doctor/windows-quickstart?cachebuster" -Destination $quickstartScript -Description "Downloading initialization script"
  }
  Write-Host "Ensuring log-on script is present"
  Set-Content -Path "C:\Temp\quickstart-logon.ps1" -Value 'Start-Process -FilePath "powershell" -ArgumentList "-File C:\Temp\quickstart.ps1 -Verbose" -verb runas'
  Write-Host "Changing $env:UserName password to 'MegabyteLabs' so we can automatically log back in" -ForegroundColor Black -BackgroundColor Cyan
  $NewPassword = ConvertTo-SecureString "MegabyteLabs" -AsPlainText -Force
  Set-LocalUser -Name $env:UserName -Password $NewPassword
  Write-Host "Turning on auto-logon" -ForegroundColor Black -BackgroundColor Cyan
  $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
  Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$env:username" -type String
  Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "MegabyteLabs" -type String
  if (!(Get-ScheduledJob -Name ContinueQuickstartJob)) {
    Write-Host "Enabling script launch on login.." -ForegroundColor Black -BackgroundColor Cyan
    $trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
    Register-ScheduledJob -Trigger $trigger -FilePath "C:\Temp\quickstart-logon.ps1" -Name ContinueQuickstartJob
  }
  Restart-Computer -Force
}

# @description Reboot and continue script after reboot (if required)
function RebootAndContinueIfRequired {
  if (!(Test-Path "C:\Temp\pending-reboot-installed")) {
    Write-Host "Installing PendingReboot module" -ForegroundColor Black -BackgroundColor Cyan
    Install-Module -Name PendingReboot -Force
    New-Item "C:\Temp\pending-reboot-installed"
  }
  Import-Module PendingReboot -Force
  if ((Test-PendingReboot).IsRebootPending) {
    RebootAndContinue
  }
}

# @description Ensure all Windows updates have been applied and then starts the provisioning process
function EnsureWindowsUpdated {
    if (!(Test-Path "C:\Temp\pswindowsupdate-installed")) {
      Write-Host "Installing update module" -ForegroundColor Black -BackgroundColor Cyan
      Install-Module -Name PSWindowsUpdate -Force
      New-Item "C:\Temp\pswindowsupdate-installed"
    }
    Write-Host "Ensuring all the available Windows updates have been applied." -ForegroundColor Black -BackgroundColor Cyan
    Import-Module PSWindowsUpdate -Force
    Get-WUInstall -AcceptAll -IgnoreReboot
    Write-Host "Checking if reboot is required." -ForegroundColor Black -BackgroundColor Cyan
    RebootAndContinueIfRequired
}

# @description Ensures Microsoft-Windows-Subsystem-Linux feature is available
function EnsureLinuxSubsystemEnabled {
    $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
    if ($wslenabled.State -eq "Disabled") {
        Write-Host "Enabling Microsoft-Windows-Subsystem-Linux" -ForegroundColor Black -BackgroundColor Cyan
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    }
}

# @description Ensure VirtualMachinePlatform feature is available
function EnsureVirtualMachinePlatformEnabled {
    $vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State
    if ($vmenabled.State -eq "Disabled") {
        Write-Host "Enabling VirtualMachinePlatform" -ForegroundColor Black -BackgroundColor Cyan
        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    }
}

# @description Ensures Ubuntu 20.04 is installed on the system from a .appx file
function EnsureUbuntuAPPXInstalled {
    if(!(Test-Path "C:\Temp\UBUNTU2004.appx")) {
        Write-Host "Downloading Ubuntu APPX" -ForegroundColor Black -BackgroundColor Cyan
        Start-BitsTransfer -Source "https://aka.ms/wslubuntu2004" -Destination "C:\Temp\UBUNTU2004.appx" -Description "Downloading Ubuntu 20.04 WSL image"
    }
    $ubu2004appxinstalled = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu20.04onWindows
    if (!$ubu2004appxinstalled) {
        Write-Host "Adding Ubuntu APPX" -ForegroundColor Black -BackgroundColor Cyan
        Add-AppxPackage -Path "C:\Temp\UBUNTU2004.appx"
    }
}

# @description Automates the process of setting up the Ubuntu 20.04 WSL environment
function SetupUbuntuWSL {
    Write-Host "Set default WSL version to 1 (required for bridged eth0 adapter)" -ForegroundColor Black -BackgroundColor Cyan
    wsl --set-default-version 1
    Write-Host "Setting up Ubuntu WSL" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "install --root" -Wait -NoNewWindow
    $username = $env:username.ToLower()
    Write-Host "Adding a user" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "run adduser $username --gecos 'First,Last,RoomNumber,WorkPhone,HomePhone' --disabled-password" -Wait -NoNewWindow
    Write-Host "Adding user to sudo group" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "run usermod -aG sudo $username" -Wait -NoNewWindow
    Write-Host "Enabling passwordless sudo privileges" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "run echo '$username ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" -Wait -NoNewWindow
    Write-Host "Setting default user" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "config --default-user $username" -Wait -NoNewWindow
}

# @description Ensures Docker Desktop is installed (which requires a reboot)
function EnsureDockerDesktopInstalled {
    if (!(Test-Path "C:\Temp\docker-desktop-rebooted")) {
      Write-Host "Installing Docker Desktop for Windows" -ForegroundColor Black -BackgroundColor Cyan
      choco install -y docker-desktop
      New-Item "C:\Temp\docker-desktop-rebooted"
      RebootAndContinue
    }
    # & 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    # Write-Host "Waiting for Docker Desktop to come online" -ForegroundColor Black -BackgroundColor Cyan
    # Start-Sleep -s 30
}

# @description Enables WinRM connectivity
function EnableWinRM {
    Write-Host "Enabling WinRM.." -ForegroundColor Black -BackgroundColor Cyan
    $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
    $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
    (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
    powershell.exe -ExecutionPolicy ByPass -File $file -Verbose -EnableCredSSP -DisableBasicAuth -ForceNewSSLCert -SkipNetworkProfileCheck
}

# @description Run the playbook
function RunPlaybook {
    Write-Host "Running quickstart.sh in WSL environment" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "run curl -sSL https://gitlab.com/megabyte-labs/gas-station/-/raw/master/scripts/quickstart.sh > quickstart.sh && bash quickstart.sh" -Wait -NoNewWindow
    Write-Host "Running quickstart continue command in WSL environment" -ForegroundColor Black -BackgroundColor Cyan
    Start-Process "ubuntu.exe" -ArgumentList "run bash ~/.config/ansible-playbook-continue-command.sh" -Wait -NoNewWindow
}

# @description Install Chocolatey
function InstallChocolatey {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# @description The main logic for the script - enable Windows features, set up Ubuntu WSL, and install Docker Desktop
# while continuing script after a restart.
function ProvisionWindowsWSLAnsible {
    if (!(Test-Path "C:\Temp\installed-package-providers")) {
      Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
      New-Item "C:\Temp\installed-package-providers"
    }
    EnsureWindowsUpdated
    EnableWinRM
    EnsureLinuxSubsystemEnabled
    EnsureVirtualMachinePlatformEnabled
    EnsureUbuntuAPPXInstalled
    SetupUbuntuWSL
    InstallChocolatey
    EnsureDockerDesktopInstalled
    RunPlaybook
    if (!!(Get-ScheduledJob -Name ContinueQuickstartJob)) {
      Write-Host "Removing ContinueQuickstartJob" -ForegroundColor Black -BackgroundColor Cyan
      Unregister-ScheduledJob -Name ContinueQuickstartJob
    }
    Write-Host "Removing C:\Temp and all its contents" -ForegroundColor Black -BackgroundColor Cyan
    Remove-Item -path "C:\Temp" -recurse -force
    Write-Host "All done! Make sure you change your password. It was set to 'MegabyteLabs'" -ForegroundColor Black -BackgroundColor Cyan
    Read-Host "Press ENTER to exit"
}

ProvisionWindowsWSLAnsible
