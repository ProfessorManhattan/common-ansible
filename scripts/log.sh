#!/usr/bin/env bash

# @file .common/scripts/log.sh
# @brief Logger that logs pretty console messages
# @description
#   This file contains several functions that log content in different formats. The available
#   log functions include:
#
#   * `error` - Logs an error message
#   * `info` - Logs a regular message
#   * `star` - Logs a message with a star icon at the beginning
#   * `start` - Logs a message that a timer has been started and starts a timer
#   * `stop` - Logs a stop message and stops the timer started by the `start` function
#   * `success` - Logs a success message
#   * `warn` - Logs a warning message
#
#   If the variable `LOG_PREFIX` is set then the log messages will start with its value. And
#   if the `LOG_SUFFIX` is set then the log messages will end with its value.
#
#   If Node.js is present and the `$container` environment variable is not set to `docker` then
#   the class will automatically start logging pretty error messages. If Node.js is not available
#   or the `$container` variable is set to `docker`, then the `ENHANCED_LOGGING` variable must
#   be set after Node.js becomes available. In addition, you should set the `NODE_PATH` variable
#   equal to `NODE_PATH="$(npm root -g):$NODE_PATH"` to ensure the `signale` logging works
#   as expected.

if commandExists node; then
  NODE_PATH="$(npm root -g):$NODE_PATH"
  export NODE_PATH
  if [ "${container:=}" != 'docker' ]; then
    ENHANCED_LOGGING=true
  fi
fi

function signale() {
  node -e 'require("signale").'"$1"'({prefix: "'"${LOG_PREFIX:=}"'", message:"'"$2"'", suffix: "'"${LOG_SUFFIX:=}"'"})'
}

function error() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale error "$1"
  else
    echo "ERROR: $1"
  fi
}

function info() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale note "$1"
  else
    echo "INFO: $1"
  fi
}

function star() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale star "$1"
  else
    echo "STAR: $1"
  fi
}

function start() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale start "$1"
  else
    echo "BEGIN: $1"
  fi
}

function stop() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale stop "$1"
  else
    echo "SUCCESS: $1"
  fi
}

function success() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale success "$1"
  else
    echo "SUCCESS: $1"
  fi
}

function warn() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale warn "$1"
  else
    echo "WARNING: $1"
  fi
}

export -f error
export -f info
export -f star
export -f start
export -f stop
export -f success
export -f warn
