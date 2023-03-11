# terminal

[![Publish Docker image](https://github.com/brona90/terminal/actions/workflows/docker-image.yml/badge.svg)](https://github.com/brona90/terminal/actions/workflows/docker-image.yml)

## This is a Dockerfile that bootstraps an Debian image via apt with

- autoconf
- make
- rlwrap
- build-essential
- curl
- tree
- fasd
- fontconfig
- git
- sudo
- tmux
- vim
- emacs
- wget
- procps
- htop
- dirmngr
- gpg
- gawk
- autoconf
- gettext
- libssl-dev
- zlib1g-dev
- zsh

## Creates a USER from ARG USERNAME defaulting to gdfoster (me)

## COPYies all scripts ending in .sh to the image

## Runs the scripts in the following order

### btop.sh

- installs `btop` from latest release in github <https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz>
  
### cheat.sh

- installs `cht.sh` from <https://cht.sh> as root

### asdf.sh

- installs `asdf` from <https://asdf-vm.com/>
- adds all plugins listed in `.tool-versions`
- installs all versions of plugins listed in `.tool-versions`

### oh-my-zsh.sh

- installs oh-my-zsh from <https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh>
  - also installs plugins via git:
    - zsh-history-substring-search
    - fast-syntax-highlighting
    - zsh-alias-finder
    - asdf.plugin.zsh

### config_setup.sh

- pulls dot file style config from my config repo at <https://github.com/brona90/config>
- creates config alias
- pulls submodules
  - ohmytmux <https://github.com/gpakosz/.tmux>
  - doomemacs <https://github.com/doomemacs/doomemacs>

### emacs.sh

- installs doomemacs from it's bin cloned in submodule with `config_setup.sh`

### tmux.sh

- installs ohmytmux and applies config repo dot files

### ttyd.sh

- installs browser based tty from <https://github.com/tsl0922/ttyd>

## The default CMD is to run gotty at ARG TTYPORT defaulting to 8080
