#!/bin/bash

set -e

mix compile
mix docs
echo "Documentation has been generated!"
open ./doc/index.html
