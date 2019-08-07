#!/bin/bash

set -e

variables=( "$@" )

echo ""
for varname in "${variables[@]}"
do
  echo "$varname=${!varname}"
done
echo ""
