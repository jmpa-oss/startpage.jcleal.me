#!/usr/bin/env bash
# cleans up the repository built off this template, when first created.

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check project root
[[ ! -d .git ]] \
  && die "must be run from repository root directory"

# check deps
deps=(aws)
for dep in "${deps[@]}"; do
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ ${#missing[@]} -ne 0 ]]; then
  [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
  die "missing dep${s}: ${missing[*]}"
fi

# retrieve variables
GITHUB_REPOSITORY="jmpa-oss/jcleal.me"
name="${GITHUB_REPOSITORY##*/}"
name="${name^^}" # uppercase
name="${name,,}" # lowercase
# safeName=$(<<< "$name" sed 's/[^a-zA-Z0-9]//g' | tr '[:upper:]' '[:lower:]')

# retrieve GitHub token
token=$(aws ssm get-parameter --name "/tokens/github" \
--query "Parameter.Value" --output text --with-decryption) \
  || die "failed to retrieve GitHub token from paramstore"

# retrieve repository information
resp=$(curl -s "https://api.github.com/repos/jmpa-oss/$name" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: bearer $token") \
  || die "failed to retrieve $name repository info"
desc=$(<<< "$resp" jq -r '.description') \
  || die "failed to parse $name repository info"

# update README.md
data="$(cat .github/workflows/template-cleanup/README.md)"
data="${data//%WEBSITE%/$name}"       # replace repository name.
data="${data//%DESCRIPTION%/$desc}"   # update repository description.
$data > ./README.md                   # overwrite existing README.md

# remove template-specific files.
rm -rf \
./github/workflows/template-cleanup.yml \
./github/template-cleanup \
./update-templates.sh
