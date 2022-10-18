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

### cheat.sh

- installs cht.sh from <https://cht.sh> as root

### asdf.sh

- installs asdf from <https://asdf-vm.com/>
- adds all plugins listed in .tool-versions
- installs all versions of plugins listed in .tool-versions

### config.sh

- pulls dot file style config from my config repo at <https://github.com/brona90/config>
- creates config alias
- pulls submodules
  - yadr <https://github.com/skwp/dotfiles>
  - spacemacs <https://github.com/syl20bnr/spacemacs>
  - ohmytmux <https://github.com/gpakosz/.tmux>

### emacs.sh

- installs spacemacs and pulls dependencies from .spacemacs cloned above from config repo

### yadr.sh

- installs yadr for vim and zsh configurations and config repo dot files

### tmux.sh

- installs ohmytmux and applieds config repo dot files

### ttyd.sh

- installs browser based tty from <https://github.com/tsl0922/ttyd>

## The default CMD is to run gotty at ARG TTYPORT defaulting to 8080

## The github action builds and pushes sucessful builds to dockerhub at brona90/terminal:<BUILD_TAG>
