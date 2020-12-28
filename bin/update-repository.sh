#!/usr/bin/env bash
# a basic script to clean up the logs in GitHub Actions for updating a repository using this template.
#
# NOTE: this should not be run locally.

echo "##[group]Configuring GitHub user"
git config user.name 'GitHub Actions'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
echo "##[endgroup]"

echo "##[group]Checking for any files that have changed"
./bin/update-template.sh
echo "##[endgroup]"

echo "##[group]Pushing"
git push origin HEAD:master
echo "##[endgroup]"
