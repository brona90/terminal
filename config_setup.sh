cd ${HOME}

git clone --bare https://github.com/brona90/config.git ${HOME}/.cfg

function config {
  /usr/bin/git --git-dir=${HOME}/.cfg/ --work-tree=${HOME} $@
}

config checkout master
config config status.showUntrackedFiles no
config submodule update --init --recursive &&

emacs -nw -batch -u ${USERNAME} -q -kill
# emacs -nw -batch -u ${USERNAMEema} -q -kill &&

. $HOME/.asdf/asdf.sh

cd ${HOME}/.yadr &&
rake install &&

ln -sf ${HOME}/.tmux/.tmux.conf ${HOME}/.tmux.conf



# go get github.com/yudai/gotty
