#!/bin/bash

set -e
export MIX_ENV=test

if [[ -L "$0" ]] && [[ -e "$0" ]] ; then
  script_file="$(readlink "$0")"
else
  script_file="$0"
fi

scripts_dir="$(dirname -- "$script_file")"
export $(cat "$scripts_dir/.env" | xargs)
"$scripts_dir/check-vars.sh" "in scripts/.env file" "ENABLE_DIALYZER"

mix deps.get
mix deps.compile
mix compile --warnings-as-errors
mix credo --strict
mix coveralls.html
mix docs

if [ "$ENABLE_DIALYZER" = true ] ; then
  mix dialyzer --halt-exit-status
fi

echo "Congratulations! Pre-commit hook checks passed!"
