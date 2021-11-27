#!/usr/bin/env bash

# @file test/darwin/test.sh
# @brief A script that is used to test the role's macOS compatibility via a
#   [GitHub action](https://gitlab.com/megabyte-labs/common/ansible/-/blob/master/files-role/.github/workflows/macOS.yml).

TEST_TYPE='darwin'

# @description Ensure Ansible is installed
if ! type ansible &> /dev/null; then
  pip3 install ansible
fi

# @description Ensure Ansible Galaxy dependencies are installed
if [ -f requirements.yml ]; then
  ansible-galaxy install -r requirements.yml
fi

# @description Symlink the Ansible Galaxy role name to the working directory one level up
ROLE_NAME="$(grep "role:" test/darwin/test.yml | sed 's^- role: ^^' | xargs)"
ln -s "$(basename "$PWD")" "../$ROLE_NAME"

# @description Back up files and then copy replacements (i.e. ansible.cfg)
function backupAndCopyFiles() {
  if [ -f ansible.cfg ]; then
    cp ansible.cfg ansible.cfg.bak
  fi
  cp "test/$TEST_TYPE/ansible.cfg" ansible.cfg
}

# @description Restore files that were backed up (i.e. ansible.cfg)
function restoreFiles() {
  if [ -f ansible.cfg.bak ]; then
    mv ansible.cfg.bak ansible.cfg
  fi
}

# @description Back up files, run the play, and then restore files
backupAndCopyFiles
ansible-playbook -i "test/$TEST_TYPE/inventory" "test/$TEST_TYPE/test.yml" || { restoreFiles; exit 1 }
restoreFiles

