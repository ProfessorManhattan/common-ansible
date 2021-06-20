#!/bin/bash

# Logs an error message
function error() {
  echo "ERROR: $1"
}

# Logs an info message
function info() {
  echo "INFO $1"
}

# Logs a regular log message
function log() {
  echo "LOG: $1"
}

# Logs a success message
function success() {
  echo "SUCCESS: $1"
}

# Logs a warning message
function warn() {
  echo "WARN: $1"
}

export -f error
export -f info
export -f log
export -f success
export -f warn
