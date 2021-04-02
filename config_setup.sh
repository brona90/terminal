git clone --bare https://github.com/brona90/config.git ${HOME}/.cfg
function config {
   /usr/bin/git --git-dir=${HOME}/.cfg/ --work-tree=${HOME} $@
 }
config checkout master
config config status.showUntrackedFiles no
config submodule update --init --recursive &&
cd ${HOME}/.yadr &&
rake install &&
emacs -nw -batch -u ${USER} -q -kill
emacs -nw -batch -u ${USER} -q -kill &&
ln -sf ${HOME}/.tmux/.tmux.conf ${HOME}/.tmux.conf
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash &&
chmod +x ${HOME}/.nvm/nvm.sh &&
. ${HOME}/.nvm/nvm.sh &&
nvm install --lts
nvm use default
npm i -g spaceship-prompt
/usr/local/go/bin/go get github.com/yudai/gotty
