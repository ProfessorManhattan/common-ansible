#Requires -RunAsAdministrator

# @file scripts/quickstart.ps1
# @brief This script will help you easily take care of the requirements and then run [Gas Station](https://github.com/megabyte-labs/gas-station)
#   on your Windows computer.
# @description
#   1. This script will enable Windows features required for WSL.
#   2. It will reboot and continue where it left off.
#   3. Ensures Windows WinRM is active and configured.
#   4. Installs and pre-configures the WSL environment.
#   5. Ensures Docker Desktop is installed
#   6. Reboots and continues where it left off.
#   7. The playbook is run.

# Uncomment this to provision with WSL instead of Docker
# $ProvisionWithWSL = 'True'
$QuickstartScript = "C:\Temp\quickstart.ps1"
$QuickstartShellScript = "C:\Temp\quickstart.sh"
# Change this to modify the password that the user account resets to
$UserPassword = 'MegabyteLabs'

# @description Used to log styled messages
function Log($message) {
  Write-Host ' POWERSHELL ' -ForegroundColor Black -BackgroundColor Cyan -NoNewline
  Write-Host -ForegroundColor White ' ' -NoNewline
  Write-Host $message
}

# @description Checks to make sure the PowerShell instance is an Administrator instance
function CheckForAdminRights() {
  $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
  $princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
  if(!$princ.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $powershell = [System.Diagnostics.Process]::GetCurrentProcess()
    $psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
    $psi.Arguments = '-file ' + $script:MyInvocation.MyCommand.Path
    $psi.Verb = "runas"
    [System.Diagnostics.Process]::Start($psi) | Out-Null
    return $false
  } else {
    return $true
  }
}

# @description Checks for admin privileges and if there are none then open a new instance with Administrator rights
$AdminRights = CheckForAdminRights
$AdminRights
if($AdminRights){
  Read-Host
} else {
  Read-Host "This script requires Administrator privileges. Press ENTER to escalate to Administrator privileges."
  [Environment]::Exit(0)
}

New-Item -ItemType Directory -Force -Path C:\Temp
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# @description Prepares the machine to automatically continue installation after a reboot
function PrepareForReboot {
  if (!(Test-Path $QuickstartScript)) {
    Log "Ensuring the recursive update script is downloaded"
    Start-BitsTransfer -Source "https://install.doctor/windows-quickstart" -Destination $QuickstartScript -Description "Downloading initialization script"
  }
  Log "Ensuring start-up script is present"
  Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Gas Station.bat" "PowerShell.exe -ExecutionPolicy RemoteSigned -Command `"Start-Process -FilePath powershell -ArgumentList '-File C:\Temp\quickstart.ps1 -Verbose' -verb runas`""
  $LocalUser = (whoami).Substring((whoami).LastIndexOf('\') + 1)
  $AccountType = Get-LocalUser -Name $LocalUser | Select-Object -ExpandProperty PrincipalSource
  if ($AccountType -eq 'Local') {
    Log "Changing $env:Username password to '$UserPassword' so we can automatically log back in"
    $NewPassword = ConvertTo-SecureString "$UserPassword" -AsPlainText -Force
    Set-LocalUser -Name $env:Username -Password $NewPassword
    Log "Turning on auto-logon"
    $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
    Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
    Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$env:Username" -type String
    Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "MegabyteLabs" -type String
  } else {
    Log "Local user's account is a $AccountType account so auto-logging in after reboot is not supported"
  }
}

# @description Reboot and continue script after reboot
function RebootAndContinue {
  PrepareForReboot
  Restart-Computer -Force
}

# @description Reboot and continue script after reboot (if required)
function RebootAndContinueIfRequired {
  if (!(Get-Module "PendingReboot")) {
    Log "Installing PendingReboot module"
    Install-Module -Name PendingReboot -Force
  }
  Import-Module PendingReboot -Force
  if ((Test-PendingReboot).IsRebootPending) {
    RebootAndContinue
  }
}

# @description Ensure all Windows updates have been applied and then starts the provisioning process
function EnsureWindowsUpdated {
  if (!(Get-Module "PSWindowsUpdate")) {
    Log "Installing update module"
    Install-Module -Name PSWindowsUpdate -Force
  }
  Log "Ensuring all the available Windows updates have been applied."
  Import-Module PSWindowsUpdate -Force
  Get-WUInstall -AcceptAll -IgnoreReboot
  Log "Checking if reboot is required."
  RebootAndContinueIfRequired
}

# @description Ensures Microsoft-Windows-Subsystem-Linux feature is available
function EnsureLinuxSubsystemEnabled {
  $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
  if ($wslenabled.State -eq "Disabled") {
    Log "Enabling Microsoft-Windows-Subsystem-Linux"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
  }
}

# @description Ensure VirtualMachinePlatform feature is available
function EnsureVirtualMachinePlatformEnabled {
  $vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State
  if ($vmenabled.State -eq "Disabled") {
    Log "Enabling VirtualMachinePlatform"
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
  }
}

# @description Ensures Ubuntu 22.04 is installed on the system from a .appx file
function EnsureUbuntuAPPXInstalled {
  if(!(Test-Path "C:\Temp\UBUNTU2204.appx")) {
    Log "Downloading Ubuntu APPX"
    Start-BitsTransfer -Source "https://aka.ms/wslubuntu2204" -Destination "C:\Temp\UBUNTU2204.appx" -Description "Downloading Ubuntu 22.04 WSL image"
  }
  # TODO: Ensure this is the appropriate AppxPackage name
  $Ubuntu2204APPXInstalled = Get-AppxPackage -Name CanonicalGroupLimited.Ubuntu22.04onWindows
  if (!$Ubuntu2204APPXInstalled) {
    Log "Adding Ubuntu APPX"
    Add-AppxPackage -Path "C:\Temp\UBUNTU2204.appx"
  }
}

# @description Automates the process of setting up the Ubuntu 22.04 WSL environment
function SetupUbuntuWSL {
  Log "Setting up Ubuntu WSL"
  Start-Process "ubuntu.exe" -ArgumentList "install --root" -Wait -NoNewWindow
  $UsernameLowercase = $env:Username.ToLower()
  Log "Adding a user"
  Start-Process "ubuntu.exe" -ArgumentList "run adduser $UsernameLowercase --gecos 'First,Last,RoomNumber,WorkPhone,HomePhone' --disabled-password" -Wait -NoNewWindow
  Log "Adding user to sudo group"
  Start-Process "ubuntu.exe" -ArgumentList "run usermod -aG sudo $UsernameLowercase" -Wait -NoNewWindow
  Log "Enabling passwordless sudo privileges"
  Start-Process "ubuntu.exe" -ArgumentList "run echo '$UsernameLowercase ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers" -Wait -NoNewWindow
  Log "Setting default user"
  Start-Process "ubuntu.exe" -ArgumentList "config --default-user $UsernameLowercase" -Wait -NoNewWindow
}

# @description Ensures Docker Desktop is installed (which requires a reboot)
function EnsureDockerDesktopInstalled {
  if (!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
    Log "Installing Docker Desktop for Windows"
    choco install -y docker-desktop
    Log "Ensuring WSL version is set to 2 (required for Docker Desktop)"
    wsl --set-default-version 2
    RebootAndContinue
  }
}

# @description Attempts to run a minimal Docker container and instructs the user what to do if it is not working
function EnsureDockerFunctional {
  Log "Ensuring WSL version is set to 2 (required for Docker Desktop)"
  wsl --set-default-version 2
  Log "Running test command (i.e. docker run --rm hello-world)"
  docker run --rm hello-world
  if ($?) {
    Log "Docker Desktop is operational! Continuing.."
  } else {
    Log "Updating WSL's kernel"
    wsl --update
    Log "Shutting down / rebooting WSL"
    wsl --shutdown
    & 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    Log "Waiting for Docker Desktop to come online"
    Start-Sleep -s 30
    docker run --rm hello-world
    if ($?) {
      Log "Docker is now running and operational! Continuing.."
    } else {
      Log "**************"
      Log "Docker Desktop does not appear to be functional yet. If you used this script, Docker Desktop should load on boot. Follow these instructions:"
      Log "1. Open Docker Desktop if it did not open automatically and accept the agreement if one is presented."
      Log "2. If Docker Desktop opens a dialog that says WSL 2 installation is incomplete then click the Restart button."
      Log "3. Press ENTER here to attempt to proceed."
      Log "4. Optionally, configure Docker to start up on boot by going to Settings -> General."
      Log "**************"
      Read-Host "Press ENTER to continue (after Docker Desktop stops displaying warning modals)"
      EnsureDockerFunctional
    }
  }
}

# @description Enables WinRM connectivity
function EnableWinRM {
  # Download and run the Ansible WinRM script
  Log "Enabling WinRM.."
  $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
  $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
  (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
  powershell.exe -ExecutionPolicy ByPass -File $file -Verbose -EnableCredSSP -DisableBasicAuth -ForceNewSSLCert -SkipNetworkProfileCheck
  # Generate OpenSSL configuration and encryption keys
  Log "Ensuring OpenSSL is installed"
  choco install -y -r openssl
  $UsernameLowercase = $env:Username.ToLower()
  $OpenSSLConfig = "C:\Temp\openssl.conf"
  Set-Content -Path $OpenSSLConfig -Value @"
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req_client]
extendedKeyUsage = clientAuth
subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:$UsernameLowercase@localhost
"@
  $UserPEMPath = Join-Path "C:\Temp" user.pem
  $KeyPEMPath = Join-Path "C:\Temp" key.pem
  Log "Generating PEM files with OpenSSL"
  & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" req -x509 -nodes -days 365 -newkey rsa:2048 -out $UserPEMPath -outform PEM -keyout $KeyPEMPath -subj "/CN=$UsernameLowercase" -extensions v3_req_client 2>&1
  #Remove-Item $OpenSSLConfig -Force
  # Configure WinRM to use the generated configurations / credentials
  Log "Importing PEM certificates"
  Import-Certificate -FilePath $UserPEMPath -CertStoreLocation cert:\LocalMachine\root
  $WinRMCert = Import-Certificate -FilePath $UserPEMPath -CertStoreLocation cert:\LocalMachine\TrustedPeople
  $PasswordCred = ConvertTo-SecureString -AsPlainText -Force $UserPassword
  $WinRMCreds = New-Object System.Management.Automation.PSCredential($UsernameLowercase, $PasswordCred) -ea Stop
  Log "Configuring WinRM to use the certificates"
  New-Item -Path WSMan:\localhost\ClientCertificate -Subject "$UsernameLowercase@localhost" -URI * -Issuer $WinRMCert.Thumbprint -Credential $WinRMCreds -Force
  Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
  # Restart WinRM
  Log "Restarting WinRM"
  Restart-Service -Name WinRM -Force
}

# @description Run the playbook with Docker
function RunPlaybookDocker {
  Set-Location -Path "C:\Temp"
  $CurrentLocation = Get-Location
  $WorkDirectory = Split-Path -leaf -path (Get-Location)
  if (!(Test-Path $QuickstartShellScript)) {
    Log "Ensuring the quickstart shell script is downloaded"
    Start-BitsTransfer -Source "https://install.doctor/quickstart" -Destination $QuickstartShellScript -Description "Downloading initialization shell script"
  }
  Log "Acquiring LAN IP address"
  $HostIPValue = (Get-NetIPConfiguration | Where-Object -Property IPv4DefaultGateway).IPv4Address.IPAddress
  if ($HostIPValue -is [array]) {
    $HostIP = $HostIPValue[0]
  } else {
    $HostIP = $HostIPValue
  }
  PrepareForReboot
  Log "Provisioning environment with Docker using $HostIP as the IP address"
  docker run -v $("$($CurrentLocation)"+':/'+$WorkDirectory) -w $('/'+$WorkDirectory) --add-host='windows:'$HostIP --entrypoint /bin/bash megabytelabs/updater:latest-full ./quickstart.sh
}

# @description Run the playbook with WSL
function RunPlaybookWSL {
  Log "Running quickstart.sh in WSL environment"
  Start-Process "ubuntu.exe" -ArgumentList "run curl -sSL https://gitlab.com/megabyte-labs/gas-station/-/raw/master/scripts/quickstart.sh > quickstart.sh && bash quickstart.sh" -Wait -NoNewWindow
  Log "Running quickstart continue command in WSL environment"
  Start-Process "ubuntu.exe" -ArgumentList "run cd ~/Playbooks && source ~/.profile && task ansible:quickstart" -Wait -NoNewWindow
}

# @description Install Chocolatey
function InstallChocolatey {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# @description The main logic for the script - enable Windows features, set up Ubuntu WSL, and install Docker Desktop
# while continuing script after a restart.
function ProvisionWindowsAnsible {
  Log "Ensuring Windows is updated and that pre-requisites are installed.."
  if (!(Get-PackageProvider -Name "NuGet")) {
    Log "Installing NuGet since the system is missing the required version.."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
  }
  EnsureWindowsUpdated
  InstallChocolatey
  EnableWinRM
  EnsureLinuxSubsystemEnabled
  EnsureVirtualMachinePlatformEnabled
  EnsureDockerDesktopInstalled
  EnsureDockerFunctional
  if ($ProvisionWithWSL -eq 'true') {
    EnsureUbuntuAPPXInstalled
    SetupUbuntuWSL
    RunPlaybookWSL
  } else {
    RunPlaybookDocker
  }
  Log "All done! Make sure you change your password. It was set to 'MegabyteLabs' for automation purposes."
  Read-Host "Press ENTER to exit, remove temporary files, and the start-up script"
  Remove-Item -path "C:\Temp" -Recurse -Force
  Remove-Item -path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Gas Station.bat" -Force
}

ProvisionWindowsAnsible
