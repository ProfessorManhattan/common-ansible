#!/usr/bin/env bash
# shellcheck disable=SC1091

# @file .common/scripts/init.sh
# @brief Imports log functions and installs [Task](https://github.com/go-task/task) if it is not installed

. "./.common/scripts/log.sh"

if ! type task &> /dev/null; then
  . "./.common/scripts/common.sh"
  . "./.common/scripts/software.sh"
  ensureTaskInstalled
fi
