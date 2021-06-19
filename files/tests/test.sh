#!/bin/bash

pip3 install ansible
if [ -f requirements.yml ]; then ansible-galaxy install -r requirements.yml; fi
cp tests/ansible.cfg ansible.cfg
cp tests/test.yml main.yml
ROLE_FOLDER=$(basename $PWD)
sed -i '.bak' "s^{{PROJECT_FOLDER_NAME}}^$ROLE_FOLDER^g" main.yml
ansible-playbook -i tests/inventory main.yml
