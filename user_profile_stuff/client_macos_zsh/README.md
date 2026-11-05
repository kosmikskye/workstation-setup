# To install

- Run `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Follow the prompt to give sudo access (sigh homebrew)
- Run `mkdir repositories && cd repositories && git clone https://github.com/james9001/workstation-setup.git && ./workstation-setup/user_profile_stuff/client_macos_zsh/installer.sh`
- Copy in the config in this directory into `~`. May need to run `dos2unix` on some zsh config files.
- After setting up environment, be sure to replace the `${ENV_VAR` stuff with the actual values as necessary.

### Multi-user homebrew

Turns out, multi-user homebrew actually is "possible" if you do this: alias brew="sudo -Hu user1 brew" on your user2 account where user1 is the user who installed brew. Hacky, but eh.
