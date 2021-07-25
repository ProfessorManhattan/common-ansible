#!/usr/bin/env bash
# shellcheck disable=SC1091

# @file .common/scripts/npm-prepare.sh
# @brief This file is run by the NPM 'prepare' hook in the 'package.json' file. It runs after 'npm install' is run.

. "./.common/scripts/init.sh"

task common:husky
