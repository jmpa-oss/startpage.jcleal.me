#!/usr/bin/env bash
# lint everything possible~

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check project root
[[ ! -d .git ]] \
  && die "must be run from repository root directory"

# check deps
deps=(docker)
for dep in "${deps[@]}"; do 
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ ${#missing[@]} -ne 0 ]]; then
  [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
  die "missing dep${s}: ${missing[*]}" 
fi

# lint docker
read -d '' -r cmd << @
echo "~~~ :docker: linting {}"
docker run --rm -it \
  hadolint/hadolint < {}
@
find . -name '*Dockerfile*' -type f -exec bash -c "$cmd" \;

# lint bash
read -d '' -r cmd <<@
echo "~~~ :bash: linting {}"
docker run --rm -it \
  -w /app \
  -v "$PWD:/app" \
  koalaman/shellcheck {}
@
find . -name '*.sh' -exec bash -c "$cmd" \;

# lint go
# TODO

# lint cloudformation
read -d '' -r cmd <<@
echo "~~~ :aws: :cloudformation: linting {}"
aws cloudformation validate-template --template-body "file://{}"
@
find ./cf -name '*.yml' -type f -exec bash -c "$cmd" \;


# lint sam templates
# TODO