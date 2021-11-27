#!/usr/bin/env bash

# @file test/windows/test.sh
# @brief A script that is used to test an Ansible role on Windows from a Docker container.
#
# @description
#   This script is intended to be run in a WSL environment on a Windows host to provision the Windows
#   host via Ansible using WinRM and CredSSP.

# Ensure Ansible is installed
pip3 install ansible pywinrm[credssp]

# Ensure Ansible Galaxy dependencies are installed
if [ -f requirements.yml ]; then
  ansible-galaxy install -r requirements.yml
fi

# Symlink the Ansible Galaxy role name to the working directory one level up
ROLE_NAME="$(grep "role:" test/windows/test.yml | sed 's^- role: ^^' | xargs)"
ln -s "$(basename "$PWD")" "../$ROLE_NAME"

# Copy required files and run the Ansible play
cp test/windows/ansible.cfg ansible.cfg
cp test/windows/test.yml test.yml
ansible-playbook -i test/windows/inventory test.yml
