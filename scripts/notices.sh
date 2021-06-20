#!/usr/bin/env bash

function missingDockerNotice() {
  if ! commandExists docker; then
    warn "Docker is not currently installed on your computer."
    info "You can install Docker by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/docker"
  fi
}

function missingKVMNotice() {
  if ([ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ]) && ! commandExists kvm; then
    warn "KVM is not currently installed on your computer."
    info "You can install KVM by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/kvm"
  fi
}

function missingParallelsNotice() {
  if [ "$SYSTEM" == 'Darwin' ] && ! commandExists prlctl; then
    warn "Parallels is not currently installed on your computer."
    info "You can install Parallels by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/parallels"
  fi
}

function missingVirtualBoxNotice() {
  if ([ "$SYSTEM" == 'Darwin' ] || [ "$SYSTEM" == 'Linux' ] || [ "$SYSTEM" == 'Win32' ] || [ "$SYSTEM" == 'Win64' ]) && ! commandExists VBoxManage; then
    warn "VirtualBox is not currently installed on your computer."
    info "You can install VirtualBox by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/virtualbox"
  fi
}

function missingVMWareNotice() {
  if ([ "$SYSTEM" == 'Linux' ] || [ "$SYSTEM" == 'Win32' ] || [ "$SYSTEM" == 'Win64' ]) && ! commandExists vmware; then
    warn "VMWare is not currently installed on your computer."
    info "You can install VMWare by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/vmware"
  fi
}

function missingVMWareFusionNotice() {
  if [ "$SYSTEM" == 'Darwin' ] && ! commandExists vmrun; then
    warn "VMWare Fusion is not currently installed on your computer."
    info "You can install VMWare Fusion by using the instructions in this link: https://gitlab.com/megabyte-labs/ansible-roles/vmware"
  fi
}

function missingVirtualizationPlatformsNotice() {
  missingDockerNotice
  missingKVMNotice
  missingParallelsNotice
  missingVirtualBoxNotice
  missingVMWareNotice
  missingVMWareFusion
}

export -f missingDockerNotice
export -f missingVirtualBoxNotice
export -f missingVirtualizationPlatformsNotice
