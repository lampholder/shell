#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script sets up a fresh linux account for use
if [[ $# == 0 || $1 == brutal ]]; then
    options="brutal"
    brutal=true
fi

if [[ $# == 0 || $1 == noinstall ]]; then
    options="noinstall"
    noinstall=true
fi

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    platform='mac'
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    platform='linux'
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
    platform='windows' #!?
fi

echo "OS detected: $platform"
echo "Options enabled:"
if [ $brutal ]; then
    echo "BRUTAL - will overwrite all existing files and symlinks"
fi
if [ $noinstall ]; then
    echo "NOINSTALL - will not bother trying to install anything from repos"
fi

if [ "$platform" == "linux" ]; then
    # Locale setting fun
    echo "Configuring locales"
    dpkg-reconfigure locales
    locale-gen "en_GB.UTF-8"
    echo -e 'LANG=en_GB.UTF-8\nLC_ALL=en_GB.UTF-8' > /etc/default/locale
fi

eval "curl --version"
return_code=$?
if [ "$return_code" == "0" ]; then 
    downloader="curl"
else
    eval "wget --version"
    return_code=$?
    if [ "$return_code" == "0" ]; then
        downloader="wget"
    else
        echo "This script requires at least one of curl/wget"
        exit 1
    fi
fi

function install_pkg_from_repo {
    if [ "$options" != "noinstall" ]; then
        echo "Installing from repo: $@"
        if [ "$platform" == "linux" ]; then
            apt-get -y install $@
        elif [ "$platform" == "mac" ]; then
            sudo -u $SUDO_USER brew install $@
        fi
    fi
}

install_pkg_from_repo git

git config --global user.email "lampholder@gmail.com"
git config --global user.name "Tom Lant"

CONFIG_PATH="$HOME/.toml_config"

function git_clone_or_pull {
    echo "Git clone_or_pull $2 to $1"
    if cd $1; then
        if [[ $# == 3 && "$3" == "brutal" ]]; then
            echo "Brutally overwiting any local changes"
            sudo -u $SUDO_USER git fetch --all
            sudo -u $SUDO_USER git reset --hard origin/master
        else
            sudo -u $SUDO_USER git pull
        fi
    else
        sudo -u $SUDO_USER mkdir $1
        sudo -u $SUDO_USER git clone $2 $1
    fi
}

function symlink_files_in_directory {
    for file in `find $1 -maxdepth 1 -type f`
    do
        filename=`basename $file`
        if [ -f "$2/$filename" ]; then
            target=`ls -l $2/$filename | awk '{print $11}'`
            if [ "$target" == "$1/$filename" ]; then
                echo "Symlink already in place $1/$filename -> $2/$filename"
            else
                if [ "$3" == "brutal" ]; then
                    echo "Brutally replacing $2/$filename with symlink to $1/$filename"
                    rm $2/$filename
                    sudo -u $SUDO_USER ln -s $1/$filename $2/$filename
                else
                    echo "Not replacing existing file/symlink $2/$filename"
                fi
            fi
        else
            sudo -u $SUDO_USER ln -s $1/$filename $2/$filename
        fi
    done
}

function download_file {
    if [ "$downloader" == "wget" ]; then
        sudo -u $SUDO_USER wget $1 2>/dev/null
    else
        sudo -u $SUDO_USER curl -O $1
    fi
}

git_clone_or_pull $CONFIG_PATH https://github.com/lampholder/terminal.git

# Fetch and configure fish shell
install_pkg_from_repo fish
chsh -s `which fish` $SUDO_USER

sudo -u $SUDO_USER mkdir -p ~/.config/fish/functions

symlink_files_in_directory $CONFIG_PATH/fish ~/.config/fish $options
symlink_files_in_directory $CONFIG_PATH/fish/functions ~/.config/fish/functions $options


# Fetch and configure neovim + plugins
install_pkg_from_repo libtool 
install_pkg_from_repo libtool-bin || true # We don't mind if this one fails.
install_pkg_from_repo autoconf automake cmake g++ pkg-config unzip build-essential
install_pkg_from_repo python-dev python3-dev #python3-pip

download_file https://bootstrap.pypa.io/get-pip.py
python get-pip.py

sudo -u $SUDO_USER -H pip install --user neovim
git_clone_or_pull ~/neovim https://github.com/neovim/neovim
cd ~/neovim
make install

sudo -u $SUDO_USER mkdir -p ~/.vim/autoload
sudo -u $SUDO_USER mkdir -p ~/.vim/bundle

(cd ~/.vim/autoload && download_file https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim)

symlink_files_in_directory $CONFIG_PATH/vim ~ $options

# Make Neovim use the standard vim settings.
rm -rf ~/.config/nvim
ln -s ~/.vim ~/.config/nvim
ln -s ~/.vimrc ~/.config/nvim/init.vim

# We're pulling these in from their own git reops, so let's keep them out of $CONFIG_PATH
git_clone_or_pull ~/.vim/bundle/vim-colors-solarized https://github.com/altercation/vim-colors-solarized.git
git_clone_or_pull ~/.vim/bundle/airline https://github.com/vim-airline/vim-airline.git
git_clone_or_pull ~/.vim/bundle/nerdtree https://github.com/scrooloose/nerdtree.git
git_clone_or_pull ~/.vim/bundle/surrounding https://github.com/tpope/vim-surround.git
git_clone_or_pull ~/.vim/bundle/supertab https://github.com/ervandew/supertab.git

# Getting a bit specific for python dev:
git_clone_or_pull ~/.vim/bundle/neomake https://github.com/neomake/neomake.git
git_clone_or_pull ~/.vim/bundle/jedi-vim https://github.com/davidhalter/jedi-vim
sudo -u $SUDO_USER -H pip install --user jedi
install_pkg_from_repo pylint

# This bit doesn't currently honour the 'brutal' flag
sudo -u $SUDO_USER ln -s $CONFIG_PATH/vim/plugins/* ~/.vim/bundle/


# Bash is hardcoded as the startup shell of openvz containers
if [ -f "/proc/user_beancounters" ]; then
    echo "We're inside an openvz container"
    sudo -u $SUDO_USER mv $HOME/.bashrc $HOME/.bashrc_old
    symlink_files_in_directory $CONFIG_PATH/bash ~ $options
fi
