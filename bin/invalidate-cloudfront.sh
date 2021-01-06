#!/usr/bin/env bash
# invalidate files in the CloudFront cache, to make it quicker to update the deployed website.

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

# get stack name
name="$(basename "$PWD")" \
  || die "failed to get repository name"

# get distribution id
data=$(aws cloudfront list-distributions --query 'DistributionList.Items[]') \
  || die "failed to list cloudfront distributions"
distributionId=$(<<< "$data" jq -r --arg name "$name" '.[] | select(.Comment==$name) | .Id') \
  || die "failed to parse list cloudfront distbutions response"
[[ -z "$distributionId" ]] && die "failed to find distribution id for $name"

# invalidate files
aws cloudfront create-invalidation \
  --distribution-id "$distributionId" \
  --paths "/*" \
  || die "failed to create cloudfront invalidation"
