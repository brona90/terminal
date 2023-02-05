#!/usr/bin/env bash

git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2

cd ${HOME}

. ${HOME}/.asdf/asdf.sh

for PLUGIN in $(cut -d' ' -f1 .tool-versions)
do
    echo "adding asdf plugin for $PLUGIN"
    asdf plugin add $PLUGIN || break
done

# asdf install

while read -r line
do
    asdf install $line || break
done < ${HOME}/.tool-versions

asdf reshim

ln -s $(which starship) /usr/local/bin/starship
