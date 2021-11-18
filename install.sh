#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit


sudo apt install \
	vim \
	git \
	curl

# Terminal & Shell
sudo apt install terminator
if [ -z "${ZSH:-}" ]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sed -i 's/^plugins=.*/plugins=(git sudo colored-man-pages dircycle)/g' "${HOME}/.zshrc"
fi

# Set dot files
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
find "${__dir}/configs" -type f -exec sh -c 'ln -v -s {} ${HOME}/$(basename {})' \;

# Source shell config
rcfile="${HOME}/.$(echo ${SHELL} | cut -d'/' -f 4)rc"
grep "shellrc" "${rcfile}" > /dev/null || echo "source ${HOME}/.shellrc" >> "${rcfile}"

# Install programs

## Package managers
if [ ! -x "$(command -v brew)" ]; then
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ ! -x "$(command -v arkade)" ]; then
	curl -sLS https://get.arkade.dev | sudo sh
fi

## Utilities
brew install fzf
arkade get jq

## K8s utils
arkade get docker-compose kubectl kind

## Git extensions
arkade get gh
gh extension install mislav/gh-branch
brew install git-delta

