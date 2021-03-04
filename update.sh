#!/bin/bash

# This script performs maintenance on this repository. It ensures git submodules are
# installed and then copies over base files from the modules. It also generates the
# documentation.

set -e

if [ ! -d "./modules/docs" ]; then
  cd modules
  git submodule add -b master https://gitlab.com/megabyte-space/documentation/ansible.git docs
  cd ..
else
  cd modules/docs
  git checkout master && git pull origin master
  cd ../..
fi
if [ ! -d "./modules/shared" ]; then
  cd modules
  git submodule add -b master https://gitlab.com/megabyte-space/common/shared.git
  cd ..
else
  cd modules/shared
  git checkout master && git pull origin master
  cd ../..
fi
cp -rf ./modules/shared/.github .
cp -rf ./modules/shared/.gitlab .
cp -rf ./modules/shared/.vscode .
cp ./modules/shared/.cspell.json .cspell.json
cp ./modules/shared/.editorconfig .editorconfig
cp ./modules/shared/.flake8 .flake8
cp ./modules/shared/.prettierrc .prettierrc
cp ./modules/shared/.yamllint .yamllint
cp ./modules/shared/CODE_OF_CONDUCT.md CODE_OF_CONDUCT.md
ROLE_FOLDER=$(basename "$PWD")
if [[ "$OSTYPE" == "darwin"* ]]; then
  grep -rl 'MEGABYTE_ROLE_PLACEHOLDER' ./modules/ansible/files | xargs sed -i .bak "s/MEGABYTE_ROLE_PLACEHOLDER/${ROLE_FOLDER}/g"
  find ./modules/ansible/files -name "*.bak" -type f -delete
else
  grep -rl 'MEGABYTE_ROLE_PLACEHOLDER' ./modules/ansible/files | xargs sed -i "s/MEGABYTE_ROLE_PLACEHOLDER/${ROLE_FOLDER}/g"
fi
cp -Rf ./modules/ansible/files/ .
chmod 755 .husky/pre-commit
cd ./modules/ansible
git reset --hard HEAD
cd ../..
jq -s '.[0] * .[1]' blueprint.json ./modules/docs/common.json > __bp.json | true
npx -y @appnest/readme generate --config __bp.json --input ./modules/docs/blueprint-contributing.md --output CONTRIBUTING.md | true
npx -y @appnest/readme generate --config __bp.json --input ./modules/docs/blueprint-readme.md | true
rm __bp.json
echo "Done updating meta files and generating documentation"
