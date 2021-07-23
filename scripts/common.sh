#!/usr/bin/env bash

# @file .common/scripts/common.sh
# @brief Includes common functions and initialization logic that is used by other scripts

export START_PATH="$PWD"
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
SCRIPT_PATH="$(pwd -P)"
export SCRIPT_PATH
cd "$START_PATH" || exit
export TMP_DIR=/tmp/megabytelabs
export USER_BIN_FOLDER="$HOME/.local/bin"
if [[ "$OSTYPE" == 'darwin'* ]]; then
  BASH_PROFILE="$HOME/.bash_profile"
  SYSTEM="Darwin"
elif [[ "$OSTYPE" == 'linux-gnu'* ]]; then
  BASH_PROFILE="$HOME/.bashrc"
  SYSTEM="Linux"
elif [[ "$OSTYPE" == 'cygwin' ]]; then
  SYSTEM="Win64"
elif [[ "$OSTYPE" == 'msys' ]]; then
  SYSTEM="Win64"
elif [[ "$OSTYPE" == 'win32' ]]; then
  SYSTEM="Win32"
elif [[ "$OSTYPE" == 'freebsd'* ]]; then
  SYSTEM="FreeBSD"
else
  SYSTEM="Unknown"
fi
export BASH_PROFILE
export SYSTEM

# @description Determines whether or not an executable is accessible
# @example commandExists node
function commandExists() {
  type "$1" &>/dev/null
}

# @description Verifies the SHA256 checksum of a file
# @example sha256 <file> <checksum>
function sha256() {
  if [ "$SYSTEM" == "Darwin" ]; then
    echo "$2 $1" | sha256sum --check
  elif [ "$SYSTEM" == "Linux" ]; then
    echo "$1  $2" | shasum -s -a 256 -c
  else
    echo "Support for this system type has not been added yet"
  fi
}

export -f commandExists
export -f sha256
