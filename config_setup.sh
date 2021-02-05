curl -fsSL https://starship.rs/install.sh | bash 
git clone --bare https://github.com/brona90/config.git ${HOME}/.cfg
function config {
   /usr/bin/git --git-dir=${HOME}/.cfg/ --work-tree=${HOME} $@
 }
config checkout master
config config status.showUntrackedFiles no
config submodule update --init --recursive &&
  cd ${HOME}/.yadr &&
  rake install &&
  ls -sf ${HOME}/.tmux/.tmux.conf ${HOME}/.tmux.conf
emacs -nw -batch -u ${USER} -q -kill

cd ${HOME}
