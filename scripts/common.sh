#!/usr/bin/env bash

# @file .common/scripts/common.sh
# @brief Includes common functions and initialization logic that is used by other scripts

export START_PATH="$PWD"
export SCRIPT_PATH=$(
  cd $(dirname ${BASH_SOURCE[0]})
  pwd -P
  cd $START_PATH
)
export TMP_DIR=/tmp/megabytelabs
export USER_BIN_FOLDER="$HOME/.local/bin"
if [ "$(uname)" == "Darwin" ]; then
  BASH_PROFILE="$HOME/.bash_profile"
  SYSTEM="Darwin"
elif [ "$( (substr "$(uname -s)" 1 5))" == "Linux" ]; then
  BASH_PROFILE="$HOME/.bashrc"
  SYSTEM="Linux"
elif [ "$( (substr "$(uname -s)" 1 10))" == "MINGW32_NT" ]; then
  SYSTEM="Win32"
elif [ "$( (substr "$(uname -s)" 1 10))" == "MINGW64_NT" ]; then
  SYSTEM="Win64"
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
  elif [ "$SYSTEM" == "MINGW32_NT" ]; then
    error "Windows support not added yet"
  elif [ "$SYSTEM" == "MINGW64_NT" ]; then
    error "Windows support not added yet"
  fi
}

export -f commandExists
export -f sha256
