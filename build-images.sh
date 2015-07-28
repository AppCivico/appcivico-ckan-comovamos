#!/usr/bin/env bash
set -o errexit

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "\$__dir=$__dir\n\n"

set -v

docker-compose build