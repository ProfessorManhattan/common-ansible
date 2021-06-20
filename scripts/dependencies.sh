#!/usr/bin/env bash

mkdir -p "$USER_BIN_FOLDER"
mkdir -p "$TMP_DIR"

# Ensures ~/.local/bin is in the PATH variable
function ensureLocalPath() {
  export PATH="$USER_BIN_FOLDER:$PATH"
  # shellcheck disable=SC2016
  PATH_STRING='\nexport PATH=$HOME/.local/bin:$PATH'
  if grep -L "$PATH_STRING" "$BASH_PROFILE"; then
    echo -e "$PATH_STRING" >>"$BASH_PROFILE"
    success "Updated the PATH variable to include ~/.local/bin in the $BASH_PROFILE file"
  fi
}

# Ensures the docker pushrm plugin is installed. This is used to automatically
# update the README.md embedded on the DockerHub website.
function ensureDockerPushRMInstalled() {
  info "Ensuring docker-pushrm is installed"
  DESTINATION="$HOME/.docker/cli-plugins/docker-pushrm"
  if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
    if [ "$SYSTEM" == 'Darwin' ]; then
      DOWNLOAD_SHA256=ffd208cd01287f457878d4851697477c0493c5e937d7ebfa36cca46d37bff659
      DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_darwin_amd64
    else
      DOWNLOAD_SHA256=7475cbdf63a6887bd46f44549fba6b04113b6979dc6977b3fdfb2cdd62162771
      DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_linux_amd64
    fi
    if [ ! -f "$DESTINATION" ]; then
      mkdir -p "$HOME/.docker/cli-plugins"
      wget "$DOWNLOAD_URL" -O "$DESTINATION"
      sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
      chmod +x "$DESTINATION"
      success "docker-pushrm installed to the ~/.docker/cli-plugins folder"
    else
      info "docker-pushrmis already installed"
    fi
  elif [ "$SYSTEM" == 'Win32' ]; then
    DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_386.exe
    error "Windows support has not been added yet"
  elif [ "$SYSTEM" == 'Win64' ]; then
    DOWNLOAD_URL=https://github.com/christian-korneck/docker-pushrm/releases/download/v1.7.0/docker-pushrm_windows_amd64.exe
    error "Windows support has not been added yet"
  fi
}

# Ensures DockerSlim is installed. If it is not present, it is installed to ~/.local/bin.
function ensureDockerSlimInstalled() {
  if ! commandExists docker-slim; then
    log "Installing DockerSlim"
    DESTINATION="$HOME/.local/bin/docker-slim"
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DOWNLOAD_DESTINATION=/tmp/megabytelabs/dist_mac.zip
        DOWNLOAD_SHA256=1e37007d1e69e98841f1af9a78c0eae4b419449c0fd66c9e40d7426c47d5d57e
        DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_mac.zip
        ZIP_FOLDER=dist_mac
      else
        DOWNLOAD_DESTINATION=/tmp/megabytelabs/dist_linux.tar.gz
        DOWNLOAD_SHA256=b0f1b488d33b09be8beb224d4d26cb2d3e72669a46d242a3734ec744116b004c
        DOWNLOAD_URL=https://downloads.dockerslim.com/releases/1.35.1/dist_linux.tar.gz
        ZIP_FOLDER=dist_linux
      fi
      log "Downloading DockerSlim"
      wget "$DOCKER_SLIM_DOWNLOAD_LINK" -O "$DOWNLOAD_DESTINATION"
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      if [ "$SYSTEM" == 'macOS' ]; then
        unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
      else
        mkdir "$TMP_DIR/$ZIP_FOLDER"
        tar -xzvf "$DOWNLOAD_DESTINATION" -C "$TMP_DIR/$ZIP_FOLDER"
      fi
      cp "$TMP_DIR/$ZIP_FOLDER/*" "$USER_BIN_FOLDER"
      rm -rf "${TMP_DIR:?}/$ZIP_FOLDER"
      rm "$DOWNLOAD_DESTINATION"
      chmod +x "$USER_BIN_FOLDER/docker-slim"
      chmod +x "$USER_BIN_FOLDER/docker-slim-sensor"
      success "DockerSlim installed to the ~/.local/bin folder"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      error "Windows support has not been added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      error "Windows support has not been added yet"
    fi
  else
    info "DockerSlim is already installed"
  fi
}

# Ensures jq is installed. If it is not present, it is installed to ~/.local/bin.
function ensureJQInstalled() {
  if ! commandExists jq; then
    log "Installing jq"
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DESTINATION="$HOME/.local/bin/jq"
        DOWNLOAD_SHA256=5c0a0a3ea600f302ee458b30317425dd9632d1ad8882259fcaf4e9b868b2b1ef
        DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-osx-amd64
      else
        DESTINATION="$HOME/.local/bin/jq"
        DOWNLOAD_SHA256=af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44
        DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
      fi

      log "Downloading jq"
      wget "$DOWNLOAD_URL" -O "$DESTINATION"
      sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
      chmod +x "$DESTINATION"
      success "jq installed to the ~/.local/bin folder"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win32.exe
      error "Windows support has not been added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      DOWNLOAD_URL=https://github.com/stedolan/jq/releases/download/jq-1.6/jq-win64.exe
      error "Windows support has not been added yet"
    fi
  else
    info "jq is already installed"
  fi
}

# Ensures Node.js is installed by using NVM and also makes sure
# node_modules are setup and that the pre-commit hook is setup.
function ensureNodeSetup() {
  if ! commandExists npx; then
    info "Installing NVM"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    export NVM_DIR
    # shellcheck disable=SC1090
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    info "Installing Node.js via NVM"
    nvm install node
    success "Installed Node.js"
  else
    info "Node.js appears to be installed"
  fi
}

# Ensures Packer is installed. If it is not present, it is installed to ~/.local/bin.
function ensurePackerInstalled() {
  if ! commandExists packer; then
    info "Installing Packer"
    DOWNLOAD_DESTINATION=/tmp/megabytelabs/packer.zip
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DOWNLOAD_SHA256=2dd688672157eed5d9f5126b1dd160862926ab698dc91e4ffb5a7fc2deb0b037
        DOWNLOAD_URL=https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_darwin_amd64.zip
      else
        DOWNLOAD_SHA256=9429c3a6f80b406dbddb9b30a4e468aeac59ab6ae4d09618c8d70c4f4188442e
        DOWNLOAD_URL=https://releases.hashicorp.com/packer/1.7.2/packer_1.7.2_linux_amd64.zip
      fi
      log "Downloading Packer"
      wget $DOWNLOAD_URL -O $DOWNLOAD_DESTINATION
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
      mv "$TMP_DIR/packer" "$HOME/.local/bin/packer"
      success "Successfully installed Packer to ~/.local/bin"
      rm "$DOWNLOAD_DESTINATION"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      error "Windows support not added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      error "Windows support not added yet"
    fi
  else
    info "Packer is already installed"
  fi
}

# Ensures Python 3 is installed by installing Miniconda if Python 3 is unavailable
# on the system.
function ensurePythonInstalled() {
  if ! commandExists python3; then
    log "Installing Python 3 using Miniconda"
    DOWNLOAD_DESTINATION=/tmp/megabytelabs/miniconda.sh
    MINICONDA_PATH="$HOME/.local/miniconda"
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DOWNLOAD_SHA256=b3bf77cbb81ee235ec6858146a2a84d20f8ecdeb614678030c39baacb5acbed1
        DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-MacOSX-x86_64.sh
      else
        DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh
        DOWNLOAD_SHA256=536817d1b14cb1ada88900f5be51ce0a5e042bae178b5550e62f61e223deae7c
      fi
      log "Downloading miniconda to install Python 3"
      wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DESTINATION"
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      bash "$DOWNLOAD_DESTINATION" -b -p "$MINICONDA_PATH"
      success "Python 3 and miniconda installed to ~/.local/miniconda"
      rm "$DOWNLOAD_DESTINATION"
      export PATH="$MINICONDA_BIN_FOLDER:$PATH"
      # Check to see if the "export PATH" command is already present in ~/.bashrc
      # shellcheck disable=SC2016
      PATH_STRING='\nexport PATH=$HOME/.local/miniconda/bin:$PATH'
      if grep -L "$PATH_STRING" "$BASH_PROFILE"; then
        echo -e "$PATH_STRING" >>"$BASH_PROFILE"
        success "Updated the PATH variable to include ~/.local/miniconda/bin in the $BASH_PROFILE file"
      else
        info "The ~/.local/miniconda/bin folder is already included in the PATH variable"
      fi
    elif [ "$SYSTEM" == 'Win32' ]; then
      DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Windows-x86.exe
      DOWNLOAD_SHA256=5045fb9dc4405dbba21054262b7d104ba61a8739c1a56038ccb0258f233ad646
      error "Windows support not added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      DOWNLOAD_URL=https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Windows-x86_64.exe
      DOWNLOAD_SHA256=c3a43d6bc4c4fa92454dbfa636ccb859a045d875df602b31ae71b9e0c3fec2b8
      error "Windows support not added yet"
    fi
  else
    info "Python 3 is already installed"
  fi
}

# Ensures Task is installed. If it is not present, it is installed to ~/.local/bin.
function ensureTaskInstalled() {
  if ! commandExists task; then
    log "Installing Task"
    DOWNLOAD_DESTINATION=/tmp/megabytelabs/task.tar.gz
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DOWNLOAD_SHA256=a82117a3b560f35be9d5d34a1eb6707f1cdde1e2ab9ed22cd5a72bd97682a83e
        DOWNLOAD_URL=https://github.com/go-task/task/releases/download/v3.4.3/task_darwin_amd64.tar.gz
      else
        DOWNLOAD_SHA256=1492e0d185eb7e8547136c8813e51189f59c1d9e21e5395ede9b9a40d55c796e
        DOWNLOAD_URL=https://github.com/go-task/task/releases/download/v3.4.3/task_linux_amd64.tar.gz
      fi
      info "Downloading Task"
      wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DESTINATION"
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      mkdir "$TMP_DIR/task"
      tar -xzvf "$DOWNLOAD_DESTINATION" -C "$TMP_DIR/task"
      mv "$TMP_DIR/task" "$HOME/.local/bin/task"
      success "Successfully installed Task to ~/.local/bin"
      rm "$DOWNLOAD_DESTINATION"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      error "Windows support not added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      error "Windows support not added yet"
    fi
  else
    info "Task is already installed"
  fi
}

# Ensures Vagrant is installed. If it is not present, it is installed to ~/.local/bin.
function ensureVagrantInstalled() {
  if ! commandExists vagrant; then
    log "Installing Vagrant"
    if [ "$SYSTEM" == 'Darwin' ]; then
      if commandExists brew; then
        brew install --cask vagrant
      else
        error "Unable to install Vagrant because Homebrew is not installed"
        info "Follow the instructions on https://brew.sh/ to install Homebrew"
      fi
    elif [ "$SYSTEM" == 'Linux' ]; then
      DOWNLOAD_DESTINATION=/tmp/megabytelabs/vagrant_linux.zip
      DOWNLOAD_SHA256=6dced262e5001d96baf99cad4bf75c30ab1e04092c28bb18078f3f0db1123d2c
      DOWNLOAD_URL=https://releases.hashicorp.com/vagrant/2.2.16/vagrant_2.2.16_linux_amd64.zip
      info "Downloading Vagrant"
      wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DESTINATION"
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      unzip "$DOWNLOAD_DESTINATION" -d "$TMP_DIR"
      mv "$TMP_DIR/vagrant" "$HOME/.local/bin/vagrant"
      success "Successfully installed Vagrant to ~/.local/bin"
      rm "$DOWNLOAD_DESTINATION"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      error "Windows support not added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      error "Windows support not added yet"
    fi
  else
    info "Vagrant is already installed"
  fi
}

# Ensures yq is installed. If it is not present, it is installed to ~/.local/bin.
function ensureYQInstalled() {
  if ! commandExists yq; then
    log "Installing yq"
    DESTINATION="$HOME/.local/bin/yq"
    if [ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]; then
      if [ "$SYSTEM" == 'Darwin' ]; then
        DOWNLOAD_SHA256=b8022412841288a1ed5bfa51b3899631b566e2d9508f3ae55d4e0b9a1b6ac3a6
        DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_darwin_amd64
      else
        DOWNLOAD_SHA256=c0a7ea321579c6019f00ff4a46cc2f64ce903aa01ec52de21befe0f93e4a6ca1
        DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_linux_amd64
      fi
      log "Downloading yq"
      wget "$DOWNLOAD_URL" -O "$DESTINATION"
      sha256 "$DESTINATION" "$DOWNLOAD_SHA256"
      chmod +x "$DESTINATION"
      success "yq successfully installed to the ~/.local/bin folder"
      ensureLocalPath
    elif [ "$SYSTEM" == 'Win32' ]; then
      DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_windows_386.exe
      error "Windows support has not been added yet"
    elif [ "$SYSTEM" == 'Win64' ]; then
      DOWNLOAD_URL=https://github.com/mikefarah/yq/releases/download/v4.9.5/yq_windows_amd64.exe
      error "Windows support has not been added yet"
    fi
  else
    info "yq is already installed"
  fi
}

export -f ensureDockerPushRMInstalled
export -f ensureDockerSlimInstalled
export -f ensureJQInstalled
export -f ensureNodeSetup
export -f ensurePackerInstalled
export -f ensurePythonInstalled
export -f ensureTaskInstalled
export -f ensureVagrantInstalled
export -f ensureYQInstalled
