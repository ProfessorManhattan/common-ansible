#!/usr/bin/env bash

# @file tests/macos/test.sh
# @brief A script that is used to test the role's macOS compatibility via GitHub actions.

# Ensure Ansible is installed
pip3 install ansible

# Ensure Ansible Galaxy dependencies are installed
if [ -f requirements.yml ]; then
  ansible-galaxy install -r requirements.yml
fi

# Symlink Ansible Galaxy role name to the working directory one level up
ROLE_NAME="$(cat tests/macos/test.yml | grep role: | sed 's^- role: ^^' | xargs)"
ln -s echo "$(basename $PWD)" "../$ROLE_NAME"

# Copy required files and run the Ansible play
cp tests/macos/ansible.cfg ansible.cfg
cp tests/macos/test.yml test.yml
ansible-playbook -i tests/macos/inventory test.yml
