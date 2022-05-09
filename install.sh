#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit
set -o xtrace

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
	vim git curl wget \
	gnome-shell-extensions terminator \
	fzf autojump

# Vim
vim -es -u configs/.vimrc -i NONE -c "PlugInstall" -c "qa"

# Gnome extensions
extensions=( "primary_input_on_lockscreensagidayan.com.v2" "wsmatrixmartin.zurowietz.de.v33" )
for extension in "${extensions[@]}"; do
	file="${extension}.shell-extension.zip"
	wget "https://extensions.gnome.org/extension-data/${file}"
	uuid=$(unzip -c "${file}" metadata.json | grep uuid | cut -d \" -f4)
	mkdir -p "${HOME}/.local/share/gnome-shell/extensions/${uuid}"
	unzip -q "${file}" -d "${HOME}/.local/share/gnome-shell/extensions/${uuid}/"
	gnome-extensions enable "${uuid}"
	rm -f "${file}"
done

# Terminal & Shell
if [ -n "${ZSH:-}" ]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	sed -i 's/^plugins=.*/plugins=(git sudo colored-man-pages dircycle)/g' "${HOME}/.zshrc"
fi

# Set dot files
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
find "${__dir}/configs" -type f -exec sh -c 'ln -v -s {} ${HOME}/$(basename {})' \;

# Source shell config
rcfile="${HOME}/.$(basename "${SHELL}")rc"
grep "shellrc" "${rcfile}" > /dev/null || echo "source ${HOME}/.shellrc" >> "${rcfile}"
source "${HOME}/.shellrc"

# Install programs

## Package managers
if [ ! -x "$(command -v arkade)" ]; then
	curl -sLS https://get.arkade.dev | sudo sh
fi

sudo arkade system install go

## Utilities
wget https://github.com/dandavison/delta/releases/download/0.12.1/git-delta_0.12.1_amd64.deb
sudo dpkg -i git-delta_0.12.1_amd64.deb
rm -rf git-delta_0.12.1_amd64.deb

arkade get jq

## K8s utils
arkade get docker-compose kubectl kind

## Git extensions
arkade get gh
# gh extension install mislav/gh-branch
