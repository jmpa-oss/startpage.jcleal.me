#!/usr/bin/env bash
# lint everything possible~

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check project root
[[ ! -d .git ]] \
  && die "must be run from repository root directory"

# check deps
deps=(docker aws)
for dep in "${deps[@]}"; do
  hash "$dep" 2>/dev/null || missing+=("$dep")
done
if [[ ${#missing[@]} -ne 0 ]]; then
  [[ ${#missing[@]} -gt 1 ]] && { s="s"; }
  die "missing dep${s}: ${missing[*]}"
fi

# lint dockerfiles
echo "##[group]Linting dockerfiles"
read -d '' -r cmd << @
echo "~~~ :docker: linting {}"
docker run --rm \
  hadolint/hadolint < {}
@
find . -name '*Dockerfile*' -type f -exec bash -c "$cmd" \;
echo "##[endgroup]"

# lint bash
echo "##[group]Linting bash"
read -d '' -r cmd <<@
echo "~~~ linting {}"
docker run --rm \
  -w /app \
  -v "$PWD:/app" \
  koalaman/shellcheck {}
@
find . -name '*.sh' -exec bash -c "$cmd" \;
echo "##[endgroup]"

# lint cf?
if [[ -d ./cf ]]; then
  echo "##[group]Linting cloudformation"
  read -d '' -r cmd <<@
echo "~~~ :aws: :cloudformation: linting {}"
aws cloudformation validate-template --template-body "file://{}"
@
  find ./cf -name '*.yml' -type f -exec bash -c "$cmd" \;
  echo "##[endgroup]"
fi
