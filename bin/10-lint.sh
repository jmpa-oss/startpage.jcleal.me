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
read -d '' -r cmd << @
echo "##[group]Linting {}"
docker run --rm \
  hadolint/hadolint < {}
echo "##[endgroup]"
@
find . -name '*Dockerfile*' -type f -exec bash -c "$cmd" \;

# lint bash
read -d '' -r cmd <<@
echo "##[group]Linting {}"
docker run --rm \
  -w /app \
  -v "$PWD:/app" \
  koalaman/shellcheck {}
echo "##[endgroup]"
@
find . -name '*.sh' -exec bash -c "$cmd" \;

# lint cf?
if [[ -d ./cf ]]; then
  read -d '' -r cmd <<@
echo "##[group]Linting {}"
aws cloudformation validate-template --template-body "file://{}"
echo "##[endgroup]"
@
  find ./cf -name '*.yml' -type f -exec bash -c "$cmd" \;
fi
