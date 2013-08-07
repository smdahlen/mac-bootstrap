#!/usr/bin/env bash

#
# Bootstraps a mac by installing homebrew, common tools, personal dotfiles,
# and an updated ruby environment.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)
ruby_version='1.9.3-p392'

# starts sudo keepalive as described at https://gist.github.com/cowboy/3118588
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# installs homebrew
if ! [ -e /usr/local/bin/brew ]; then
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" </dev/null
fi

# installs common tools
# TODO: fix sudo password prompt (subshell issue?)
if ! hash packer 2>/dev/null; then
    brew tap homebrew/binary
    brew install bash mercurial vim git bash-completion curl-ca-bundle packer
    if ! grep "^$(brew --prefix)/bin/bash" /etc/shells >/dev/null; then
        echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells >/dev/null
    fi
    echo 'Update shell by running chsh -s /usr/local/bin/bash'
fi

# installs rbenv and the specified ruby version
if ! hash rbenv 2>/dev/null; then
    brew install rbenv
    brew install ruby-build
    PATH=~/.rbenv/shims:~/.rbenv/bin:$PATH
    rbenv install $ruby_version
    rbenv global $ruby_version
    rbenv rehash
fi

# installs personal dotfiles
if ! [ -d ~/.homesick ]; then
    gem install --no-rdoc --no-ri homesick
    rbenv rehash
    homesick clone smdahlen/dotfiles
    homesick symlink smdahlen/dotfiles
fi

cd $old_dir

unset dir old_dir ruby_version
