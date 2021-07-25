'use strict';

/* eslint-disable space-before-function-paren */

import inquirer from 'inquirer';
import signale from 'signale';

signale.info(
  'Choose a desktop environment below to run the Ansible play on. After choosing, a VirtualBox VM will be created. Then, the Ansible play will run on the VM. After it is done, the VM will be left open for inspection. Please do get carried away ensuring everything is working as expected and looking for configuration optimizations that can be made. The operating systems should all be the latest stable release but might not always be the latest version.'
);
promptForDesktop();

/**
 * Prompts the user for the operating system they wish to launch and test the
 * Ansible play against.
 */
async function promptForDesktop() {
  const response = await inquirer.prompt([
    {
      type: 'list',
      name: 'operatingSystem',
      message: 'Which desktop operating system would you like to test the Ansible play against?',
      choices: ['Archlinux', 'CentOS', 'Debian', 'Fedora', 'macOS', 'Ubuntu', 'Windows']
    }
  ]);
  const env = response.operatingSystem.toLowerCase();
  console.log(env);
}
