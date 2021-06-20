#!/bin/bash

# Logs an error message
error() {
  echo "ERROR: $1"
}

# Logs an info message
info() {
  echo "INFO $1"
}

# Logs a regular log message
log() {
  echo "LOG: $1"
}

# Logs a success message
success() {
  echo "SUCCESS: $1"
}

# Logs a warning message
warn() {
  echo "WARN: $1"
}

export -f error
export -f info
export -f log
export -f success
export -f warn
