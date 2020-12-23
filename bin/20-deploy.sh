#!/usr/bin/env bash
# deploy a cf template to authed AWS account.

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }
usage() { echo "usage: $0 <template-name>"; exit 64; }

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

# check args
template="$1"
[[ $template == "" ]] && usage
if [[ $template == cf/*.yml ]]; then
  template=${template/cf\//}
  template=${template/\.yml/}
fi

# check template
path="cf/$template.yml"
[[ -f "$path" ]] \
  || die "missing $path"

# check auth
aws sts get-caller-identity &>/dev/null \
  || die "unable to connect to AWS; are you authed?"

# the current registered domain
domain="jcleal.me"

# validate domain
domains=$(aws route53domains list-domains --region us-east-1) \
  || die "failed to list route53 domains"
expectedDomain=$(<<<"$domains" jq -r --arg domain "$domain" \
  '.Domains[] | select(.DomainName==$domain) | .DomainName') \
  || die "failed to parse route53 domains response"
[[ -z "$expectedDomain" ]] \
  && die "missing $domain domain; this needs to be manually set up"

# get hosted zone id
hostedZoneId=$(aws route53 list-hosted-zones-by-name \
  --query "HostedZones[?Name=='$domain.'].Id" \
  --output text) \
  || die "failed to get hosted zone id for $domain"
hostedZoneId=${hostedZoneId/\/hostedzone\//}

# get cert arn
certs=$(aws acm list-certificates --region us-east-1) \
  || die "failed to list acm certificates"
cert=$(<<<"$certs" jq -r --arg domain "$domain" \
  '.CertificateSummaryList[] | select(.DomainName==$domain) | .CertificateArn') \
  || die "failed to parse acm certificates response"

# get stack name
name="$(basename "$PWD")" \
  || die "failed to get repository name"
stack="$name-$template"
[[ $template == "template" ]] \
  && { stack="$name"; }

# deploy stack
echo "##[group]Deploying $stack"
aws cloudformation deploy \
  --template-file "$path" \
  --stack-name "$stack" \
  --no-fail-on-empty-changeset \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides \
    "Repository=$name" \
    "HostedZoneId=$hostedZoneId" \
    "AcmCertificateArn=$cert" \
    "Domain=$domain" \
  --tags "repository=$name" \
  || die "failed to deploy cf $stack"
echo "##[endgroup]"
