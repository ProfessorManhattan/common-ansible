# @file scripts/quickstart.ps1
# @brief This script allows you to perform a complete install of [Gas Station](https://github.com/megabyte-labs/gas-station)
#   on your Windows computer with a single line of code. It is intended to be run on a freshly installed copy of Windows 11.
#   A fresh install is really the only way we can guarantee a successful install.
# @description
#   1. This script will enable Windows features required for WSL / Docker Desktop.
#   2. It will reboot and continue where it left off whenever a reboot is needed. It will reset the user's password to MegabyteLabs
#      if the account is a local one (i.e. not a Microsoft online account) so that there is minimal required interaction.
#   3. Ensures Windows WinRM is active and configured.
#   4. Performs set up of the WSL environment (if the WSL method is active - currently, only Docker has been thoroughly tested)
#   5. Ensures Docker Desktop is installed and that the daemon is running.
#   6. The LAN IP is detected and that same IP that the Windows computer has is used by Docker to provision with Ansible.

# @description Configuration variables
$AdminUsername = 'Gas'
$AdminPassword = 'CrownNebulaSpaceButterfly888()'
$LocalUserText = 'C:\Temp\local-user.txt'
$OEMUsername = 'Starflake'
# Uncomment this to provision with WSL instead of Docker
# $ProvisionWithWSL = 'True'
$QuickstartScript = "C:\Temp\quickstart.ps1"
$QuickstartShellScript = "C:\Temp\quickstart.sh"

# @description Shared common variables
$LocalUser = (whoami).Substring((whoami).LastIndexOf('\') + 1)
$NetProfile = Get-NetConnectionProfile

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
    # $powershell = [System.Diagnostics.Process]::GetCurrentProcess()
    # $psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
    # $psi.Arguments = '-file ' + $script:MyInvocation.MyCommand.Path
    # $psi.Verb = "runas"
    # [System.Diagnostics.Process]::Start($psi) | Out-Null
    return $false
  } else {
    return $true
  }
}

# @description Changes all networks to private which is a requirement of WinRM. This could probably
#   be improved from a security standpoint but this is just for Windows which will probably only be
#.  getting provisioned in VMs. Perhaps when there is better support for Ansible SSH on Windows
#.  we can get rid of WinRM entirely. Until then, this method is just going to do it like all the
#.  tutorials on Google / StackOverflow. Ansible does provide some good documentation on using
#.  shared keys - for now this will be on the backlog. Pull requests welcome from anyone who needs
#.  Windows WinRM locked down.
function EnsureNetworksPrivate() {
  Log 'Ensuring all networks are in private mode (a requirement for WinRM connections)'
  $NetProfile = Get-NetConnectionProfile
  foreach ($InterfaceIndex in $NetProfile.InterfaceIndex) {
    Set-NetConnectionProfile -InterfaceIndex $InterfaceIndex -NetworkCategory Private
  }
}

# @description Ensures the network states are restored to their original privacy level after the play is finished.
function EnsureNetworksReset() {
  Log 'Resetting network connection privacy states to their original levels'
  foreach($Profile in $NetProfile) {
    Set-NetConnectionProfile -InterfaceIndex $Profile.InterfaceIndex -NetworkCategory $Profile.NetworkCategory
  }
}

# @description Prepares the machine to automatically continue installation after a reboot
function PrepareForReboot {
  if (!(Test-Path $QuickstartScript)) {
    Log "Ensuring the recursive update script is downloaded"
    Start-BitsTransfer -Source "https://install.doctor/windows-quickstart" -Destination $QuickstartScript -Description "Downloading initialization script"
  }
  Log "Ensuring start-up script is present"
  Set-Content -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Gas Station.bat" "PowerShell.exe -ExecutionPolicy RemoteSigned -Command `"Start-Process -FilePath powershell -ArgumentList '-File $QuickstartScript -Verbose' -verb runas`""
  Log "Creating temporary local administrator named $AdminUsername"
  net user $AdminUsername /add
  net localgroup administrators $AdminUsername /add
  Log "Setting $AdminUsername password to $AdminPassword"
  $SecureAdminPassword = ConvertTo-SecureString "$AdminPassword" -AsPlainText -Force
  Set-LocalUser -Name $AdminUsername -Password $SecureAdminPassword
  # For domain user password, use the following:
  # Set-ADAccountPassword Tom -NewPassword $NewPassword -Reset
  Log "Turning on auto-logon"
  $RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'
  Set-ItemProperty $RegistryPath 'AutoAdminLogon' -Value "1" -Type String
  Set-ItemProperty $RegistryPath 'DefaultUsername' -Value "$AdminUsername" -type String
  # Following line needs to use unencrypted password
  Set-ItemProperty $RegistryPath 'DefaultPassword' -Value "$AdminPassword" -type String
}

# @description Reboot and continue script after reboot
function RebootAndContinue {
  PrepareForReboot
  Restart-Computer -Force
}

# @description Reboot and continue script after reboot (if required)
function RebootAndContinueIfRequired {
  if (!(Get-Module -ListAvailable -Name 'PendingReboot')) {
    Log "Installing PendingReboot module"
    Install-Module -Name 'PendingReboot' -Force
  }
  # Status method used by the update installer
  if (((Test-PendingReboot).IsRebootPending) -or (Get-WURebootStatus -Silent)) {
    RebootAndContinue
  }
}

# @description Ensure all Windows updates have been applied and then starts the provisioning process
function EnsureWindowsUpdated {
  if (!(Get-Module -ListAvailable -Name 'PSWindowsUpdate')) {
    Log "Installing update module"
    Install-Module -Name 'PSWindowsUpdate' -Force
  }
  Log 'Ensuring updates are enabled for other Microsoft products besides Windows'
  Add-WUServiceManager -MicrosoftUpdate -Confirm:$false
  Log "Ensuring all the available Windows updates have been applied."
  PrepareForReboot
  Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
  Log "Checking if reboot is required."
  RebootAndContinueIfRequired
}

# @description Ensures Microsoft-Windows-Subsystem-Linux feature is available
function EnsureLinuxSubsystemEnabled {
  $wslenabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux | Select-Object -Property State
  if ($wslenabled.State -eq "Disabled") {
    Log "Enabling Microsoft-Windows-Subsystem-Linux"
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    RebootAndContinue
  }
}

# @description Ensure VirtualMachinePlatform feature is available
function EnsureVirtualMachinePlatformEnabled {
  $vmenabled = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform | Select-Object -Property State
  if ($vmenabled.State -eq "Disabled") {
    Log "Enabling VirtualMachinePlatform"
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    RebootAndContinue
  }
}

# @description Ensures Ubuntu 22.04 is installed on the system from a .appx file
function EnsureUbuntuAPPXInstalled {
  Log 'Ensuring Ubuntu 22.04 WSL environment is installed'
  $Ubuntu2204APPXInstalled = Get-AppxPackage -Name 'CanonicalGroupLimited.Ubuntu22.04LTS'
  if (!$Ubuntu2204APPXInstalled) {
    Log "Ensuring WSL version is set to 2 (required for Docker Desktop)"
    wsl --set-default-version 2
    Log "Updating WSL's kernel"
    wsl --update
    if(!(Test-Path "C:\Temp\UBUNTU2204.appx")) {
      Log "Downloading Ubuntu APPX"
      Start-BitsTransfer -Source "https://aka.ms/wslubuntu2204" -Destination "C:\Temp\UBUNTU2204.appx" -Description "Downloading Ubuntu 22.04 WSL image"
    }
    Log "Adding Ubuntu APPX"
    Add-AppxPackage -Path "C:\Temp\UBUNTU2204.appx"
    UpgradeLinuxWSLKernel
    SetupUbuntuWSL
  }
}

# @description Automates the process of setting up the Ubuntu 22.04 WSL environment
function SetupUbuntuWSL {
  Log "Ensuring WSL version is set to 2 (required for Docker Desktop)"
  wsl --set-default-version 2
  Log "Updating WSL's kernel"
  wsl --update
  Log "Shutting down / rebooting WSL"
  wsl --shutdown
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

# @description Update to WSL2 Linux kernel required by Docker Desktop
function UpgradeLinuxWSLKernel {
  if(!(Test-Path "C:\Temp\wsl-update.msi")) {
    Log "Downloading WSL2 Linux kernel package"
    Start-BitsTransfer -Source "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi" -Destination "C:\Temp\wsl-update.msi" -Description "Downloading WSL2 Linux kernel"
    Start-Process "C:\Temp\wsl-update.msi" -ArgumentList "/quiet /passive"
  }
}

# @description Ensures Docker Desktop is installed (which requires a reboot)
function EnsureDockerDesktopInstalled {
  if (!(Test-Path "C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
    Log "Installing Docker Desktop for Windows"
    if (!(Test-Path 'C:\Temp\Docker Desktop Installer.exe')) {
      $DockerSource = 'https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe'
      Start-BitsTransfer -Source $DockerSource -Destination 'C:\Temp\Docker Desktop Installer.exe' -Description 'Downloading Docker Desktop for Windows'
    }
    Log "Running Docker Desktop installation using the CLI"
    Start-Process 'C:\Temp\Docker Desktop Installer.exe' -Wait 'install --accept-license --backend=wsl-2 --quiet'
    if (Test-Path("$LocalUserText")) {
      $InitialUser = cat "$LocalUserText"
    } else {
      Log 'C:\Temp\local-user.txt is not present so we will assume it is an OEM build'
      $InitialUser = $OEMUsername
    }
    Log "Adding $InitialUser to the docker-users group"
    net localgroup docker-users "$InitialUser" /add
    Log 'Pausing script to give Docker time before forced reboot'
    Start-Sleep -s 14
    RebootAndContinue
  }
}

# @description Attempts to run a minimal Docker container and instructs the user what to do if it is not working
function EnsureDockerFunctional {
  Log "Running test command (i.e. docker run --rm hello-world)"
  docker run --rm hello-world | Out-Null
  if ($?) {
    Log "Docker Desktop is operational! Continuing.."
  } else {
    Start-Sleep -s 14
    EnsureDockerFunctional
  }
}

# @description Ensures NuGet is available
function EnsureNuGet {
  $Packages = Get-PackageProvider -ListAvailable | Select-Object -Property Name
  if (!($Packages.Name -contains 'NuGet')) {
    Log "Installing NuGet since the system is missing the required version.."
    Install-PackageProvider -Name 'NuGet' -MinimumVersion 2.8.5.201 -Force
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
}

# @description More advanced procedure to establish a more secure connection (requires copying key files to Ansible host)
# Source: https://vnuggets.com/2019/08/08/ansible-certificate-authentication-to-windows/
# function EnableWinRMCertificate {
#   # Generate OpenSSL configuration and encryption keys
#   Log "Ensuring OpenSSL is installed"
#   choco install -y -r openssl
#   $UsernameLowercase = $env:Username.ToLower()
#   $OpenSSLConfig = "C:\Temp\openssl.conf"
#   # Note: This might need white space trimmed from beginning of each line since it's formatted as such
#   Set-Content -Path $OpenSSLConfig -Value @"
#     distinguished_name = req_distinguished_name
#     [req_distinguished_name]
#     [v3_req_client]
#     extendedKeyUsage = clientAuth
#     subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:$UsernameLowercase@localhost
#   "@
#   $UserPEMPath = Join-Path "C:\Temp" user.pem
#   $KeyPEMPath = Join-Path "C:\Temp" key.pem
#   Log "Generating PEM files with OpenSSL"
#   & "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" req -x509 -nodes -days 365 -newkey rsa:2048 -out $UserPEMPath -outform PEM -keyout $KeyPEMPath -subj "/CN=$UsernameLowercase" -extensions v3_req_client 2>&1
#   #Remove-Item $OpenSSLConfig -Force
#   # Configure WinRM to use the generated configurations / credentials
#   Log "Importing PEM certificates"
#   Import-Certificate -FilePath $UserPEMPath -CertStoreLocation cert:\LocalMachine\root
#   $WinRMCert = Import-Certificate -FilePath $UserPEMPath -CertStoreLocation cert:\LocalMachine\TrustedPeople
#   $PasswordCred = ConvertTo-SecureString -AsPlainText -Force $UserPassword
#   $WinRMCreds = New-Object System.Management.Automation.PSCredential($UsernameLowercase, $PasswordCred) -ea Stop
#   Log "Configuring WinRM to use the certificates"
#   New-Item -Path WSMan:\localhost\ClientCertificate -Subject "$UsernameLowercase@localhost" -URI * -Issuer $WinRMCert.Thumbprint -Credential $WinRMCreds -Force
#   Set-Item -Path WSMan:\localhost\Service\Auth\Certificate -Value $true
#   # Restart WinRM
#   Log "Restarting WinRM"
#   Restart-Service -Name WinRM -Force
# }

# @description Force script to run when provisioning user first logs in
function RunOnce() {
  Log 'Configuring RunOnce script'
  $KeyName = 'RunGasStationProvisioner'
  $Command = '%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File C:\Temp\quickstart.ps1'
  if (-not ((Get-Item -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce).$KeyName )) {
    New-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name $KeyName -Value $Command -PropertyType ExpandString
  } else {
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce' -Name $KeyName -Value $Command -PropertyType ExpandString
  }
}

# @description Run the playbook with Docker
function RunPlaybookDocker {
  Set-Location -Path "C:\Temp" | Out-Null
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
  docker run -it -v $("$($CurrentLocation)"+':/'+$WorkDirectory) -w $('/'+$WorkDirectory) -e MOLECULE_GROUP="windows" -e ANSIBLE_PASSWORD="$AdminPassword" -e ANSIBLE_USER="$AdminUsername" --add-host='standard:'$HostIP --entrypoint /bin/bash megabytelabs/updater:latest-full ./quickstart.sh
  echo $?
  Log 'Status code of docker command above'
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
  choco --help | Out-Null
  if (!$?) {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }
}

# @description The main logic for the script - enable Windows features, set up Ubuntu WSL, and install Docker Desktop
# while continuing script after a restart.
function ProvisionWindowsAnsible {
  EnsureNuGet
  EnsureWindowsUpdated
  EnsureNetworksPrivate
  EnableWinRM
  EnsureLinuxSubsystemEnabled
  EnsureVirtualMachinePlatformEnabled
  EnsureUbuntuAPPXInstalled
  EnsureWindowsUpdated
  EnsureDockerDesktopInstalled
  EnsureDockerFunctional
  if ($ProvisionWithWSL -eq 'true') {
    RunPlaybookWSL
  } else {
    RunPlaybookDocker
  }
  Log "Encounter an error? Running 'Enable-PSRemoting -SkipNetworkProfileCheck' in an Administrator PowerShell might help.."
  Log "If that does not work, this article might help: http://www.dhruvsahni.com/verifying-winrm-connectivity"
  Log "Removing temporary files"
  Set-Location -Path "$HOME" | Out-Null
  Remove-Item -path "C:\Temp" -Recurse -Force | Out-Null
  Remove-Item -path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Gas Station.bat" -Force | Out-Null
  Log "Removing temporary local administrator account named $AdminUsername"
  Remove-LocalUser -Name "$AdminUsername"
  EnsureNetworksReset
  Log 'Re-enabling UAC'
  Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 1
  Log 'Re-restricting the ExecutionPolicy'
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted -Force
  Read-Host "Finished! Press ENTER to close the process.."
}

# @description Ensure the user can run scripts
Log 'Ensure ExecutionPolicy is Unrestricted'
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
Log 'Ensuring C:\Temp exists'
if (!(Test-Path 'C:\Temp')) {
  New-Item 'C:\Temp' -ItemType Directory
}

# @description Checks for admin privileges and if there are none then open a new instance with Administrator rights
$AdminAccess = CheckForAdminRights
if ($AdminAccess) {
  Log "Current session is an Administrator session.. Good."
  Log 'Ensuring UAC is disabled system-wide'
  Set-ItemProperty -Path REGISTRY::HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0
  if ($LocalUser -ne $AdminUsername) {
    Log "Writing LocalUser name to $LocalUserText so provisioning user can add them to the Docker group"
    echo "$LocalUser" > "$LocalUserText"
    RunOnce
    RebootAndContinue
  }
  ProvisionWindowsAnsible
} else {
  if (!(Test-Path $QuickstartScript)) {
    Log "Ensuring the recursive update script is downloaded"
    Start-BitsTransfer -Source "https://install.doctor/windows-quickstart" -Destination $QuickstartScript -Description "Downloading initialization script"
  }
  Log "This script requires Administrator privileges. Respawning instance with necessary privileges."
  Start-Process PowerShell -verb RunAs -ArgumentList "-NoExit -File $QuickstartScript"
}
