#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find ${__dir}/configs -type f -exec sh -c 'ln -s {} ${HOME}/$(basename {})' \;

