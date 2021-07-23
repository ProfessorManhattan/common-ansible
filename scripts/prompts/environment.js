"use strict"

/* eslint-disable space-before-function-paren */

import inquirer from "inquirer"
import signale from "signale"
import * as fs from "fs"

signale.info(
  "Answer the prompt below to switch between environments. Each environment should be a folder with folders and files you wish to link to from the root of the project. They should normally consist of a host_vars, group_vars, inventory, and files folder (but can contain any files/folders you wish to link). Each environment should have its own folder in the `environments/` folder titled as the name of the environment. After you select an answer, the script will symlink all of the items in the environments folder to the root as long as there is not anything except a symlink in the target location (i.e. it will overwrite symlinks but not files)."
)
promptForEnv()

/**
 * Prompts the user for the environment they wish to use by asking them
 * which folder in the environments/ folder to use to create symlinks
 * to the root of the project.
 */
async function promptForEnv() {
  const response = await inquirer.prompt([
    {
      type: "list",
      name: "environment",
      message: "Which environment would you like to use?",
      choices: getDirectories("environments/"),
    },
  ])
  const env = response.environment
  const elements = fs.readdirSync("environments/" + env + "/")
  let flawless = true
  for (const element of elements) {
    const target = "./environments/" + env + "/" + element
    if (fs.existsSync(element)) {
      fs.lstat(element, (err, stats) => {
        if (err) {
          return signale.error("The logger encountered a fatal error!", err)
        }
        if (!stats.isSymbolicLink()) {
          signale.error(
            "The `" +
              element +
              "` target in your project root is not a symbolic link. If you plan on using this feature then you should store any folders/files you wish to be considered part of an environment in the `environments/{{ environment_name }}/` folder. You can then use this script to handle creating the symbolic links for you. We are skipping the creation of the symlink to `environments/" +
              env +
              "/" +
              element +
              "` because there is a non-symbolic link with the same name in the root of the project."
          )
          flawless = false
        } else {
          fs.unlinkSync(element)
          fs.symlinkSync(target, element, (err, stats) => {
            if (err) {
              return signale.error("The logger encountered a fatal error!", err)
            }
            signale.note(element + " is now linked to environments/" + env + "/" + element + ".")
          })
        }
      })
    } else {
      fs.symlinkSync(target, element, (err, stats) => {
        if (err) {
          return signale.error("The logger encountered a fatal error!", err)
        }
        signale.note(element + "/ is now linked to environments/" + env + "/" + element + ".")
      })
    }
  }
  if (flawless) {
    signale.success("The " + env + " environment is now active.")
  } else {
    signale.warn("There was an error linking the " + env + " environment.")
  }
}

/**
 * Scans a directory for directories inside it
 *
 * @param {The path to scan for directories} path
 * @returns An array of directories located in the path
 */
function getDirectories(path) {
  return fs.readdirSync(path).filter(function (file) {
    return fs.statSync(path + "/" + file).isDirectory()
  })
}
