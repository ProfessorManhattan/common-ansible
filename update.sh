#!/bin/bash
# shellcheck disable=SC1091

# @file .common/update.sh
# @brief Ensures the project is up-to-date with the latest upstream changes
# @description
# This script performs maintenance on this repository. It includes several bash script
# libraries and then it:
#
# 1. Ensures Node, jq, Task, and yq are installed
# 2. Bootstraps the project by using Task to run initialization tasks which bootstrap the project
# 3. Notifies the user about missing software dependencies that require root priviledges to install

source "./.common/scripts/common.sh"
source "./.common/scripts/log.sh"
source "./.common/scripts/software.sh"
source "./.common/scripts/notices.sh"

if [ "${container:=}" != 'docker' ]; then
  info "Ensuring Node.js, Task, jq, and yq are installed"
  ensureNodeSetup &
  ensureJQInstalled &
  ensureTaskInstalled &
  ensureYQInstalled &
  wait
  success "Node.js, Task, jq, and yq are all installed"
fi

REPO_SUBTYPE="$(grep REPOSITORY_SUBTYPE Taskfile.yml | sed 's/.*REPOSITORY_SUBTYPE: \(.*\)/\1/')"
export REPO_SUBTYPE

cp ".common/files-$REPO_SUBTYPE/Taskfile.yml" Taskfile.yml
task start

if [ "${container:=}" != 'docker' ]; then
  missingDockerNotice
  missingVirtualBoxNotice
fi

success "Bootstrap process complete!"

cp .common/.start.sh .start.sh &
