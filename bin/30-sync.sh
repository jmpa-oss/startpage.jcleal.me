#!/usr/bin/env bash
# sync the website to s3

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

# check auth
aws sts get-caller-identity &>/dev/null \
  || die "unable to connect to AWS; are you authed?"

# check path
path="./src"
[[ -d "$path" ]] \
  || die "missing $path"

# get stack name
stack="$(basename "$PWD")" \
  || die "failed to get repository name"
stack="${stack//\./-}"

# get bucket
bucket=$(aws cloudformation describe-stacks --stack-name "$stack" \
  --query "Stacks[].Outputs[?OutputKey=='Bucket'].OutputValue" --output text) \
  || die "failed to get bucket name for $stack"

# sync to s3
echo "##[group]Syncing to s3"
aws s3 sync --delete --exact-timestamps "$path" "s3://$bucket" \
  || die "failed to sync $path to $bucket"
echo "##[endgroup]"
