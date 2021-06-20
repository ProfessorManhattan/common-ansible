#!/bin/bash
# shellcheck disable=SC1091

# @file .common/update.sh
# @brief Ensures the project is up-to-date with the latest upstream changes
# @description
#   This script performs maintenance on this repository. It includes several bash script
#   libraries and then it:
#
#   1. Ensures Node, jq, Task, and yq are installed
#   2. Bootstraps the project by using Task to run initialization tasks which bootstrap the project
#   3. Notifies the user about missing software dependencies that require root priviledges to install

set -e

source "./.common/scripts/log.sh"
source "./.common/scripts/common.sh"
source "./.common/scripts/software.sh"
source "./.common/scripts/notices.sh"

if [ "${container:=}" != 'docker' ]; then
  info "Ensuring Node.js, Task, jq, and yq are installed"
  ensureNodeSetup &
  ensureJQInstalled &
  ensureTaskInstalled &
  ensureYQInstalled &
  wait
  success "Node.js, Task, jq, and yq are all available"
fi

task requirements update

if [ "${container:=}" != 'docker' ]; then
  missingDockerNotice
  missingVirtualBoxNotice
fi
# Update shared files and install requirements
copy_project_files_and_generate_package_json
populate_alternative_descriptions
generate_ansible_charts
generate_documentation
populate_common_missing_ansible_dependencies
install_requirements
misc_fixes
