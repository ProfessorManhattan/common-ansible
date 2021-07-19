#!/bin/bash

# @file .common/lib.sh
# @brief Contains various functions unique to this repository type.

if [ "${container:=}" != 'docker' ]; then
  set -e
else
  set -ex
fi
