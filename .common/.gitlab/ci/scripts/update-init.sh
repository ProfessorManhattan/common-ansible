#!/usr/bin/env bash

# @file .gitlab/ci/scripts/update-init.sh
# @brief Script that executes before any CI update step

set -eo pipefail

echo "Update script running.."
npm install --save-dev @mblabs/eslint-config@latest
TMP="$(mktemp)"
jq 'del(."standard-version")' package.json > "$TMP"
mv "$TMP" package.json
TMP="$(mktemp)"
jq 'del(."lint-staged")' package.json > "$TMP"
mv "$TMP" package.json
mkdir -p docs
mv CODE_OF_CONDUCT.md docs || true
mv CONTRIBUTING.md docs || true
npm install --save-optional chalk inquirer signale
