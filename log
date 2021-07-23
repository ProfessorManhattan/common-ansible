#!/usr/bin/env bash

# @file .common/scripts/log-min.sh
# @brief Logger that logs pretty console messages
# @description
#   This file contains several functions that log content in different formats. It is the same as `log.sh`
#   except it gets rid of initialization tasks and a couple log functions types. The available
#   log functions include:
#
#   * `error` - Logs an error message
#   * `info` - Logs a regular message
#   * `star` - Logs a message with a star icon at the beginning
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

# @description Determines whether or not an executable is accessible
# @example commandExists node
function commandExists() {
  type "$1" &> /dev/null
}

if commandExists node; then
  if [ "${container:=}" != 'docker' ]; then
    ENHANCED_LOGGING=true
  fi
fi

function signale() {
  node -e 'const { Signale } = require("signale"); const logger = new Signale({scope: "'"${SCOPE:=}"'", types: { log: { badge: "●", color: "white", label: "info" } } }); logger.'"$1"'({prefix: "'"${LOG_PREFIX:=}"'", message:"'"$2"'", suffix: "'"${LOG_SUFFIX:=}"'"})'
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

function log() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale log "$1"
  else
    echo "LOG: $1"
  fi
}

function star() {
  if [ "$ENHANCED_LOGGING" ]; then
    signale star "$1"
  else
    echo "STAR: $1"
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

$1 "$2"
