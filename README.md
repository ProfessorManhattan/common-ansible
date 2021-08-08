<div align="center">
  <center>
    <a href="https://gitlab.com/megabyte-labs/common">
      <img width="140" height="140" alt="Common files logo" src="https://gitlab.com/megabyte-labs/common/shared/-/raw/master/logo.png" />
    </a>
  </center>
</div>
<div align="center">
  <center><h1>Common Files</h1></center>
  <center><h4 style="color: #18c3d1;">Documentation for a set of upstream repositories that house the source for many files used in hundreds of our repositories</h4></center>
</div>

<a href="#-table-of-contents" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## ➤ Table of Contents

- [➤ Overview](#overview)
- [➤ Documentation Partials and Variable Inheritence](#documentation-partials-and-variable-inheritence)
- [➤ Common File Propagation Process](#common-file-propagation-process)
- [➤ Common File Sub-Types](#common-file-sub-types)
- [➤ Sub-Type Specific Files](#sub-type-specific-files)
- [➤ Templated Files](#templated-files)
- [➤ More Information](#more-information)

<a href="#overview" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Overview

All of the projects in the [Megabyte Labs](https://megabyte.space) eco-system inherit many of their files (e.g. configuration files) from a cascade of [common file repositories](https://gitlab.com/megabyte-labs/common). Each repository includes a bundle of shared files as a submodule. The submodule is located in the `.common/` folder in the root of each project. The submodule links to the common file repository that corresponds to the type of project (e.g. Ansible projects link their `.common/` folder to the [Ansible common files repository](https://gitlab.com/megabyte-labs/common/ansible)). Each of the common file repositories houses all the data that is required for a downstream repository but many of the files in the common file repository are actually inherited from a repository even further upstream.

<a href="#documentation-partials-and-variable-inheritence" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Documentation Partials and Variable Inheritence

We encourage you to read the [documentation for our documentation partials repositories](https://gitlab.com/megabyte-labs/documentation/shared/-/blob/master/README.md) first because those repositories are the highest upstream. The documentation for the documentation partials repositories already covers how the variables stored in `common.json`, `common.{{ project_subtype }}.json`, and `variables.json` inherit from each other so we will skip the details of that process in this documentation.

<a href="#common-file-propagation-process" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Common File Propagation Process

Many of the files in all our repositories are actually housed in upstream repositories. In order to stay DRY, we use a process that propagates changes from repositories that have files intended to be used by all projects to repositories that have files for specific types of projects. The flow from upstream to the final destination downstream project follows the logic listed below:

1. When the shared documentation repository (which is the highest upstream repository) is updated, it propagates to [all the other project-type-specific documentation repositories](https://gitlab.com/megabyte-labs/documentation) by triggering their GitLab CI pipeline. It does this by using a GitLab CI script that triggers the pipelines of all the repositories stored in a CI variable (named `DOWNSTREAM_PROJECT_IDS`) which is a comma-seperated list of repository project IDs ([Link to GitLab CI configuration](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/propagate/propagate-projects.gitlab-ci.yml)).
2. When their pipelines are triggered, the project-type-specific documentation repositories update themselves in a GitLab CI pipeline ([Link to GitLab CI update script](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/update/update-docs.gitlab-ci.yml)).
3. After the project-type-specific documentation repositories are done updating and linting their new content, they propagate downstream to the project-type-specific [common file repositories](https://gitlab.com/megabyte-labs/common) by triggering the GitLab CI pipelines of the downstream projects ([Link to GitLab CI configuration](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/propagate/propagate-projects.gitlab-ci.yml)).
4. When the common files repositories' GitLab CI pipelines are triggered, they run an update process which includes grabbing data from the upstream documentation repositories as well as the [shared common file repository](https://gitlab.com/megabyte-labs/common/shared) ([Link to GitLab CI update configuration for common file repository updates](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/update/update-common.gitlab-ci.yml)).
5. After the common file repositories are done updating and linting, they propagate their changes to their final destination repositories. This is done by using a GitLab CI script that takes a comma-seperated CI variable (named `DOWNSTREAM_GROUP_IDS`) that includes the sub-groups group IDs that the common file repository is responsible for. The script takes the ID of each sub-group and uses the GitLab API to get the project ID of every project in that sub-group. With the project IDs in hand, it triggers the pipeline of each project using the GitLab API ([Link to propagation GitLab CI configuration](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/propagate/propagate-groups.gitlab-ci.yml)).
6. Finally, when the downstream project's pipelines are triggered, they update themselves via a [GitLab CI update configuration](https://gitlab.com/megabyte-labs/ci/gitlab-ci-templates/-/blob/master/update/update-project.gitlab-ci.yml). This update process calls `bash .start.sh`. `.start.sh` is a file we keep in all our repositories which ensures the `.common/` submodule is up-to-date, ensures [Task](https://taskfile.dev/#/) is installed, and then uses Task to run the project configuration/generation/update process. Using Task allows us to run all parts of the project configuration/generation/update in parallel which makes the process quick. It also has some other nice features like dependency management and conditional script execution.

<a href="#common-file-sub-types" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Common File Sub-Types

When browsing around our various common file repositories, you might notice that we have group sub-types. For the [Ansible common file repository](https://gitlab.com/megabyte-labs/common/ansible) you will see that we have multiple folders. The folders are named `files`, `files-role`, and `files-playbook`. In this case, during the project update process, the `files` are copied into both the `files-role` and `files-playbook` folders. The `files-role` and `files-playbook` folders contain files meant for all Ansible projects but files intended for their sub-types. In this case, the sub-types are `role` and `playbook` - two different types of Ansible projects that require slightly different sets of files.

Common file sub-types will always have their own group in the [Megabyte Labs GitLab group](https://gitlab.com/megabyte-labs). For example, if the common file repository is of the type Dockerfile, then the sub-groups will be:

- [ansible-molecule](https://gitlab.com/megabyte-labs/dockerfile/ansible-molecule)
- [app](https://gitlab.com/megabyte-labs/dockerfile/app)
- [ci-pipeline](https://gitlab.com/megabyte-labs/dockerfile/ci-pipeline)
- [software](https://gitlab.com/megabyte-labs/dockerfile/software)

This is because the Dockerfile group contains four sub-groups. Notice how the group names correspond to the slugs of each of the sub-types group pages.

<a href="#sub-type-specific-files" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Sub-Type Specific Files

You might also notice that we have a `package.role.json.handlebars` and `package.playbook.json.handlebars` file in the Ansible common file repository. These `package.json` files are merged (using jq) with the upstream `package.json.handlebars` during the CI process. That is why the `package.role.json.handlebars` file does not contain everything you should expect in a `package.json` file. Only the items that need to be over-written are included in the downstream `package.role.json.handlebars` file.

Note: When dealing with JSON files, the downstream repository's JSON will always take precedence. In other cases, however, upstream files will write over downstream files. The best way of figuring out which files take precedence is to read through the various CI links added to this README.

<a href="#templated-files" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## Templated Files

Many of the files included in our upstream common file repositories end with the file extension `.handlebars`. A file with the `.handlebars` extension is compiled at some point using [Handlebars](https://handlebarsjs.com/). This lets us add conditional logic and inject variables into files.

<a href="#more-information" style="width:100%"><img style="width:100%" alt="-----------------------------------------------------" src="https://gitlab.com/megabyte-labs/assets/-/raw/master/png/aqua-divider.png" /></a>

## More Information

For further information, we encourage you to look at the aforementioned GitLab CI configuration files and the scripts associated with them. This is really the best way of understanding the process because it is constantly evolving so fully documenting the process is not feasible at this point in time.
