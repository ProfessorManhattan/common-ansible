#!/bin/bash

# This script performs maintenance on this repository. It ensures git submodules are
# installed and then copies over base files from the modules. It also generates the
# documentation.

set -e

export REPO_TYPE=ansible

if [ -d .git ]; then
  git pull origin master --ff-only
  git submodule update --init --recursive
fi
if [ ! -d .common ]; then
  mkdir .common
  git submodule add -b master "https://gitlab.com/megabyte-space/common/$REPO_TYPE.git" ".common/$REPO_TYPE"
else
  cd .common
  git checkout master && git pull origin master --ff-only
  cd ../..
fi
bash .common/update.sh
