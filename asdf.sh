cd ${HOME}

. ${HOME}/.asdf/asdf.sh

for PLUGIN in $(cut -d' ' -f1 .tool-versions)
do
    echo "adding asdf plugin for $PLUGIN"
    asdf plugin add $PLUGIN || break
done

while read -r line
do 
    asdf install $line || break 
done < .tool-versions
