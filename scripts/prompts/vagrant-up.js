"use strict";

/* eslint-disable space-before-function-paren */

import { execSync } from "child_process";
import { readdirSync } from "fs";
import inquirer from "inquirer";
import signale from "signale";

signale.info("Use the following prompts to select the type of operating system and the virtualization platform you wish to use with Vagrant.");

/**
 * Prompts the user for the operating system they wish to launch and test the
 * Ansible play against.
 */
async function promptForDesktop() {
  const response = await inquirer.prompt([
    {
      type: "list",
      name: "operatingSystem",
      message: "Which desktop operating system would you like to provision?",
      choices: ["Archlinux", "CentOS", "Debian", "Fedora", "macOS", "Ubuntu", "Windows"]
    }
  ]);
  return response.operatingSystem.toLowerCase();
}

/**
 * Prompts the user for the virtualization platform they wish to use. Before presenting
 * the options some basic verification is done to ensure that only the options available
 * on the system are presented.
 */
async function promptForPlatform() {
  const platformMap = {
    "Hyper-V": "hyperv",
    KVM: "libvirt",
    Parallels: "parallels",
    VirtualBox: "virtualbox",
    "VMWare Fusion": "vmware_fusion",
    "VMWare Workstation": "vmware_workstation"
  };
  // Source: https://github.com/zacanger/is-program-installed/blob/master/index.js
  const opts = {
    stdio: "ignore"
  };

  const exec = (cmd) => execSync(cmd, opts);

  const isUnixInstalled = (program) => {
    try {
      exec(`hash ${program} 2>/dev/null`);
      return true;
    } catch {
      return false;
    }
  };

  const isDirectory = (path) => {
    try {
      readdirSync(path);
      return true;
    } catch {
      return false;
    }
  };

  const isDotDesktopInstalled = (program) => {
    const dirs = [
      process.env.XDG_DATA_HOME && process.env.XDG_DATA_HOME + "/applications",
      process.env.HOME && process.env.HOME + "/.local/share/applications",
      "/usr/share/applications",
      "/usr/local/share/applications"
    ]
      .filter(Boolean)
      .filter(isDirectory);

    const trimExtension = (x) => x.replace(/\.desktop$/, "");
    const desktopFiles = dirs
      .flatMap((x) => readdirSync(x))
      .filter((x) => x.endsWith(".desktop"))
      .map(trimExtension);

    const programTrimmed = trimExtension(program);
    return desktopFiles.includes(programTrimmed);
  };

  const isMacInstalled = (program) => {
    try {
      exec(`osascript -e 'id of application "${program}"' 2>&1>/dev/null`);
      return true;
    } catch {
      return false;
    }
  };

  const isWindowsInstalled = (program) => {
    // Try a couple variants, depending on execution environment the .exe
    // may or may not be required on both `where` and the program name.
    const attempts = [`where ${program}`, `where ${program}.exe`, `where.exe ${program}`, `where.exe ${program}.exe`];

    let success = false;
    for (const a of attempts) {
      try {
        exec(a);
        success = true;
      } catch {}
    }

    return success;
  };

  const isInstalled = (program) => [isUnixInstalled, isMacInstalled, isWindowsInstalled, isDotDesktopInstalled].some((f) => f(program));
  const choices = [];
  if (process.platform === "win32") {
    // TODO: Check if Hyper-V is enabled instead of just assuming that all Windows computers have Hyper-V enabled
    choices.push("Hyper-V");
  }
  if ((process.platform === "darwin" || process.platform === "linux") && isInstalled("kvm")) {
    choices.push("KVM");
  }
  if (process.platform === "darwin" && isInstalled("Parallels Desktop.app")) {
    choices.push("Parallels");
  }
  if (isInstalled("virtualbox")) {
    choices.push("VirtualBox");
  }
  if (process.platform === "darwin" && isInstalled("VMware Fusion.app")) {
    choices.push("VMWare Fusion");
  }
  if (process.platform !== "darwin" && isInstalled("vmware")) {
    choices.push("VMWare Workstation");
  }
  const response = await inquirer.prompt([
    {
      type: "list",
      name: "virtualizationPlatform",
      message: "Which virtualization platform would you like to use?",
      choices
    }
  ]);
  return platformMap[response.virtualizationPlatform];
}

async function run() {
  const operatingSystem = await promptForDesktop();
  const virtualizationPlatform = await promptForPlatform();
  console.log("--provider=" + virtualizationPlatform + " " + operatingSystem);
}

run();
