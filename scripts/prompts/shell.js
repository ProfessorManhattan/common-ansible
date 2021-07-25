'use strict';

/* eslint-disable space-before-function-paren */

import inquirer from 'inquirer';
import signale from 'signale';

signale.info(
  'Open a shell session quickly, safely, and easily using Docker. Select an option from the prompt below to download and shell into a Docker environment.'
);
promptForShell();

/**
 * Prompts the user for the operating system they wish to launch a shell session with.
 */
async function promptForShell() {
  const response = await inquirer.prompt([
    {
      type: 'list',
      name: 'operatingSystem',
      message: 'Which operating system would you like to open up a terminal session with?',
      choices: [
        'Archlinux',
        'CentOS 7',
        'CentOS 8',
        'Debian 9',
        'Debian 10',
        'Fedora 33',
        'Fedora 34',
        'Ubuntu 18.04',
        'Ubuntu 20.04',
        'Ubuntu 21.04'
      ]
    }
  ]);
  const choice = response.operatingSystem.toLowerCase().replace(' ', '-');
  console.log(choice);
}
