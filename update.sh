#!/bin/bash

# This script performs maintenance on Ansible repositories. It ensures git submodules are
# installed and then copies over base files from the modules. It also generates the
# documentation.

set -e

source "./.common/scripts/log.sh"
source "./.common/scripts/common.sh"
source "./.common/scripts/software.sh"
source "./.common/scripts/notices.sh"

if [ "$container" != 'docker' ]; then
  ensureNodeInstalled
  ensureJQInstalled
  ensureTaskInstalled
  ensureYQInstalled
fi

task requirements update

if [ "$container" != 'docker' ]; then
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
