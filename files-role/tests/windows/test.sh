#!/usr/bin/env bash

# @file tests/windows/test.sh
# @brief A script that is used to test the role on Windows from a Docker container
# running on the same machine via GitLab CI's shared Windows runner.

# Ensure Ansible is installed
pip3 install ansible

# Ensure Ansible Galaxy dependencies are installed
if [ -f requirements.yml ]; then
  ansible-galaxy install -r requirements.yml
fi

# Symlink Ansible Galaxy role name to the working directory one level up
ROLE_NAME="$(cat tests/windows/test.yml | grep role: | sed 's^- role: ^^' | xargs)"
ln -s echo "$(basename $PWD)" "../$ROLE_NAME"

# Copy required files and run the Ansible play
cp tests/windows/ansible.cfg ansible.cfg
cp tests/windows/test.yml test.yml
ansible-playbook -i tests/windows/inventory test.yml
