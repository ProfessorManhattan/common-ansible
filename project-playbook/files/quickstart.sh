#!/usr/bin/env bash

# @file files/quickstart.sh
# @brief Installs the playbook on the local machine with little, if any, input required
# @description
#   This script will run the `ansible:quickstart` task on the local machine without much input
#   required by the user. The `ansible:quickstart` task installs the entire playbook. It should
#   certainly be run in a VM before running it on your main computer to test whether or not you
#   like the changes. It will ask you for your sudo password at the beginning of the play and
#   after any reboots that are required. The sudo password will also be required to ensure Ansible
#   dependencies are installed prior to the playbook running.

set -eo pipefail

# @description The folder to store the Playbook files in the current user's home directory
PLAYBOOKS_DIR="Playbooks"
# @description Release URL to use when downloading [Task](https://github.com/go-task/task)
TASK_RELEASE_URL="https://github.com/go-task/task/releases/latest"

# @description Ensures ~/.local/bin is in the PATH variable on *nix machines and
# exits with an error on unsupported OS types
#
# @example
#   ensureLocalPath
#
# @set PATH string The updated PATH with a reference to ~/.local/bin
# @set SHELL_PROFILE string The preferred profile
#
# @exitcode 0 If the PATH was appropriately updated or did not need updating
# @exitcode 1 If the OS is unsupported
function ensureLocalPath() {
  case "${SHELL}" in
    */bash*)
      if [[ -r "${HOME}/.bash_profile" ]]; then
        SHELL_PROFILE="${HOME}/.bash_profile"
      else
        SHELL_PROFILE="${HOME}/.profile"
      fi
    ;;
    */zsh*)
      SHELL_PROFILE="${HOME}/.zprofile"
    ;;
    *)
      SHELL_PROFILE="${HOME}/.profile"
    ;;
  esac
  if [[ "$OSTYPE" == 'darwin'* ]] || [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    # shellcheck disable=SC2016
    local PATH_STRING='\nexport PATH=$HOME/.local/bin:$PATH'
    if grep -L "$PATH_STRING" "$SHELL_PROFILE"; then
      echo -e "$PATH_STRING" >> "$SHELL_PROFILE"
      echo "Updated the PATH variable to include ~/.local/bin in $SHELL_PROFILE"
    fi
  elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
    echo "Windows is not directly supported. Use WSL or Docker." && exit 1
  elif [[ "$OSTYPE" == 'freebsd'* ]]; then
    echo "FreeBSD support not added yet" && exit 1
  else
    echo "System type not recognized" && exit 1
  fi
}

# @description Ensures a given package is installed on a system. It will check if
# the package is already present and then attempt to install it if it is not. The
# installation will only occur on Linux systems (other systems report an error if the
# package is missing).
#
# @example
#   ensurePackageInstalled "curl"
#
# @arg $1 string The name of the package that must be present
#
# @exitcode 0 If the package is already present or if it successfully installs
# @exitcode 1 If the package needs to be installed manually or if the OS is unsupported
function ensurePackageInstalled() {
  if ! type "$1" &> /dev/null; then
    if [[ "$OSTYPE" == 'darwin'* ]]; then
      echo "$1 appears to be missing. Please install $1 to continue" && exit 1
    elif [[ "$OSTYPE" == 'linux-gnu'* ]]; then
      if [ -f "/etc/redhat-release" ]; then
        sudo yum update
        sudo yum install "$1"
      elif [ -f "/etc/lsb-release" ]; then
        sudo apt update
        sudo apt install -y "$1"
      elif [ -f "/etc/arch-release" ]; then
        sudo pacman update
        sudo pacman -S "$1"
      else
        echo "$1 is missing. Please install $1 to continue." && exit 1
      fi
    elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
      echo "Windows is not directly supported. Use WSL or Docker." && exit 1
    elif [[ "$OSTYPE" == 'freebsd'* ]]; then
      echo "FreeBSD support not added yet" && exit 1
    else
      echo "System type not recognized" && exit 1
    fi
  fi
}

# @description Ensures Task is installed to ~/.local/bin if it is not already installed. If it gets
# installed by this function then ensureLocalPath is called to ensure that the binary is accessible
# on the PATH variable.
#
# @see ensureLocalPath
#
# @example
#   ensureTaskInstalled
#
# @exitcode 0 If the package is already present or if it is installed
# @exitcode 1 If the OS is unsupported or if there was an error either installing the package or setting the PATH
function ensureTaskInstalled() {
  if ! type task &> /dev/null; then
    local CHECKSUM_DESTINATION=/tmp/megabytelabs/task_checksums.txt
    local CHECKSUMS_URL="$TASK_RELEASE_URL/download/task_checksums.txt"
    local DOWNLOAD_DESTINATION=/tmp/megabytelabs/task.tar.gz
    local TMP_DIR=/tmp/megabytelabs
    if [[ "$OSTYPE" == 'darwin'* ]] || [[ "$OSTYPE" == 'linux-gnu'* ]]; then
      if [[ "$OSTYPE" == 'darwin'* ]]; then
        local DOWNLOAD_URL="$TASK_RELEASE_URL/download/task_darwin_amd64.tar.gz"
      else
        local DOWNLOAD_URL="$TASK_RELEASE_URL/download/task_linux_amd64.tar.gz"
      fi
      mkdir -p "$(dirname "$DOWNLOAD_DESTINATION")"
      curl "$DOWNLOAD_URL" -o "$DOWNLOAD_DESTINATION"
      curl "$CHECKSUMS_URL" -o "$CHECKSUM_DESTINATION"
      local DOWNLOAD_BASENAME="$(basename "$DOWNLOAD_URL")"
      local DOWNLOAD_SHA256="$(cat "$CHECKSUM_DESTINATION" | grep "$DOWNLOAD_BASENAME" | cut -d ' ' -f 1)"
      sha256 "$DOWNLOAD_DESTINATION" "$DOWNLOAD_SHA256"
      mkdir "$TMP_DIR/task"
      tar -xzvf "$DOWNLOAD_DESTINATION" -C "$TMP_DIR/task"
      mv "$TMP_DIR/task" "$HOME/.local/bin/task"
      echo "Successfully installed Task to ~/.local/bin"
      rm "$CHECKSUM_DESTINATION"
      rm "$DOWNLOAD_DESTINATION"
      ensureLocalPath
    elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
      echo "Windows is not directly supported. Use WSL or Docker." && exit 1
    elif [[ "$OSTYPE" == 'freebsd'* ]]; then
      echo "FreeBSD support not added yet" && exit 1
    else
      echo "System type not recognized" && exit 1
    fi
  fi
}

# @description Verifies the SHA256 checksum of a file
#
# @example
#   sha256 myfile.tar.gz 5b30f9c042553141791ec753d2f96786c60a4968fd809f75bb0e8db6c6b4529b
#
# @arg $1 string The path to the file
# @arg $2 string The SHA256 signature
#
# @exitcode 0 If the checksum is valid or if a warning about the checksum software not being present is displayed
# @exitcode 1 If the OS is unsupported or if the checksum is invalid
function sha256() {
  if [[ "$OSTYPE" == 'darwin'* ]]; then
    if ! type sha256sum &> /dev/null; then
      if type brew &> /dev/null; then
        brew install coreutils
      else
        echo "WARNING: checksum validation is being skipped for $1 because both brew and sha256sum are unavailable"
      fi
    fi
    if type sha256sum &> /dev/null; then
      echo "$2 $1" | sha256sum --check
    fi
  elif [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    if ! type shasum &> /dev/null; then
      echo "WARNING: checksum validation is being skipped for $1 because the shasum program is not installed"
    else
      echo "$1  $2" | shasum -s -a 256 -c
    fi
  elif [[ "$OSTYPE" == 'cygwin' ]] || [[ "$OSTYPE" == 'msys' ]] || [[ "$OSTYPE" == 'win32' ]]; then
    echo "Windows is not directly supported. Use WSL or Docker." && exit 1
  elif [[ "$OSTYPE" == 'freebsd'* ]]; then
    echo "FreeBSD support not added yet" && exit 1
  else
    echo "System type not recognized" && exit 1
  fi
}


# @description Clone the repository if `git` is available, otherwise, use `curl` and `tar`. Also,
# if the repository is already cloned then attempt to pull the latest changes if `git` is installed.
cd ~ || exit
if [ ! -d "~/$PLAYBOOKS_DIR" ]; then
  if type git &> /dev/null; then
    git clone https://gitlab.com/ProfessorManhattan/Playbooks.git "$PLAYBOOKS_DIR"
  else
    ensurePackageInstalled "curl"
    curl https://gitlab.com/ProfessorManhattan/Playbooks/-/archive/master/Playbooks-master.tar.gz -o Playbooks.tar.gz
    ensurePackageInstalled "tar"
    tar -xzvf Playbooks.tar.gz
    mv Playbooks-master "$PLAYBOOKS_DIR"
  fi
else
  if type git &> /dev/null; then
    if [ -d "~/$PLAYBOOKS_DIR/.git" ]; then
      cd "~/$PLAYBOOKS_DIR"
      git pull origin master --ff-only
      git submodule update --init --recursive
      cd ..
    fi
  fi
fi

# @description Ensure Task is installed and properly configured and then run the `ansible:quickstart`
# task. The source to the `ansible:quickstart` task can be found
# [here](https://gitlab.com/megabyte-labs/common/shared/-/blob/master/common/.config/taskfiles/ansible/Taskfile.yml).
cd "~/$PLAYBOOKS_DIR" || exit
ensureTaskInstalled
task ansible:quickstart
