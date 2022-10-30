#!/usr/bin/env bash

set -o nounset
set -o pipefail
set -o errexit
set -o xtrace

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
	vim git curl wget \
	gnome-shell-extensions zsh terminator \
	fzf autojump

# Vim
vim -N -es -u configs/.vimrc -i NONE -c "PlugInstall" -c "qa"

# Gnome extensions
extensions=( "primary_input_on_lockscreensagidayan.com.v3" "wsmatrixmartin.zurowietz.de.v35" )
for extension in "${extensions[@]}"; do
	file="${extension}.shell-extension.zip"
	wget "https://extensions.gnome.org/extension-data/${file}"
	uuid=$(unzip -q -c "${file}" metadata.json | jq -r '.uuid')
	version=$(unzip -q -c "${file}" metadata.json | jq -r '.version')
	if ! gnome-extensions show ${uuid} || \
	   [ "$(gnome-extensions show ${uuid} | grep -i version | awk '{print $2}')" != "${version}" ]; then
		rm -rf  "${HOME}/.local/share/gnome-shell/extensions/${uuid}"
		mkdir -p "${HOME}/.local/share/gnome-shell/extensions/${uuid}"
		unzip -q "${file}" -d "${HOME}/.local/share/gnome-shell/extensions/${uuid}/"

		# GNOME need to be restarted manually with ALT + F2
		gnome-extensions enable "${uuid}"
	fi
	rm -f "${file}"
done

# Terminal & Shell

# Must log out from user session and log back in
sudo chsh -s $(which zsh)
if [ ! -d ${HOME}/.oh-my-zsh ]; then
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
sed -i 's/^plugins=.*/plugins=(git sudo colored-man-pages dircycle terraform)/g' "${HOME}/.zshrc"

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
