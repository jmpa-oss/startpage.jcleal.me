#!/usr/bin/env bash
# setup / update a repository built from this template.

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check project root
[[ ! -d .git ]] \
  && die "must be run from repository root directory"

# check remote has been setup
if [[ $(git remote show template 2>/dev/null ) ]]; then
    git remote add template "https://github.com/jmpa-oss/repo-template.git" \
        || die "failed to add remote template"
fi

# update remote
git fetch template

# check for any changes
# TODO

# merge changes
# git merge template/master