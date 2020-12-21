#!/usr/bin/env bash
# run this repository inside a docker container.

# funcs
die() { echo "$1" >&2; exit "${2:-1}"; }

# check dir
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

# run container
# TODO: