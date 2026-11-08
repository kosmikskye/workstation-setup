#!/bin/zsh

brew install --casks \
	firefox \
	visual-studio-code \
	librewolf \
	iterm2 \
	font-hack-nerd-font \
	rectangle \
	temurin \
	pgadmin4 \
	google-chrome \
	brave-browser \
	bitwarden \
	freelens \
	karabiner-elements \
	cyberduck \
	postman \
	openvpn-connect \
	vlc \
	utm \
	geekbench \
	orbstack \
	cursor \
	dbeaver-community \
	db-browser-for-sqlite

brew install \
	git \
	starship \
	tmux \
	fortune \
	lolcat \
	htop \
	neofetch \
	ncdu \
	iperf3 \
	pre-commit \
	cmatrix \
	nvm \
	dos2unix \
	rustup \
	go \
	ansible \
	sshpass \
	opentofu \
	codex \
	maven

sudo gem install catsay

xattr -d com.apple.quarantine /Applications/LibreWolf.app

# set up nvm + default node installation
if [ "$(uname -m)" = "x86_64" ]; then
	export NVM_DIR="$HOME/.nvm"
		[ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
fi
if [ "$(uname -m)" = "arm64" ]; then
	export NVM_DIR="$HOME/.nvm"
		[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
fi
mkdir -p /Users/$(whoami)/.nvm
nvm install 26
nvm alias default 26

# set up rust
rustup-init -y

# save current working dir
CURRENT_WORK_DIR=${PWD}

# convert quotes to .dat
cd /Users/$(whoami)
strfile -c % my_quotes my_quotes.dat

# install rio
cd $CURRENT_WORK_DIR
bash install-rio-macos.sh
