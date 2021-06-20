## Introduction

This repository is home to a collection of Ansible playbooks meant to provision computers and networks with the "best of GitHub". Using Ansible, you can provision your whole network relatively fast in the event of a disaster. This project is also intended to increase the security of your network by allowing you to frequently wipe, reinstall, and re-provision your network, bringing it back to its original state. This is done by backing up only what needs to be backed up (like database files and Docker volumes) to encrypted S3 buckets or git repositories. Each piece of software is included as an Ansible role. Sometimes there are multiple tools that exist that perform the same task. In these cases, extensive research is done to ensure that only the best, most-popular software makes it into our role collection.

This Ansible playbook is:

- Highly configurable (most roles come with optional variables that you can configure to change the behavior of the role)
- Compatible with all major operating systems (i.e. Windows, Mac OS X, Ubuntu, Fedora, CentOS, Debian, and even Archlinux)
- The product of a team of experts
- An amazing way to learn about developer tools that many would consider to be "the best of GitHub"
- Open to new ideas - feel free to [open an issue]({{ repository.project.playbooks}}{{ repository.location.issues }}) or [contribute]({{ repository.project.playbooks }}{{ repository.location.contributing }}) with a pull request!
