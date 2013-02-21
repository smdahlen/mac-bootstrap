#!/bin/bash

#
# Bootstraps a mac by installing homebrew, common tools, personal dotfiles,
# and an updated ruby environment.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)
ruby_version='1.9.3-p385'

# redirects standard and error output to log file
exec 3>&1 1>$dir/bootstrap.log 2>&1

# installs homebrew
if ! [ -e /usr/local/bin/brew ]; then
    echo -n 'Installing homebrew... ' >&3
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" </dev/null
    echo 'complete.' >&3
fi

# installs common tools
if ! hash irssi 2>/dev/null; then
    echo -n 'Installing common tools... ' >&3
    brew install mercurial vim git bash-completion irssi
    echo 'complete.' >&3
fi

# installs personal dotfiles
cd $dir/..
if ! [ -d dotfiles ]; then
    echo -n 'Installing personal dotfiles... ' >&3
    git clone git@github.com:smdahlen/dotfiles.git
    cd dotfiles
    git submodule init && git submodule update
    ./setup.sh
    echo 'complete.' >&3
fi

# installs rbenv and the specified ruby version
if ! hash rbenv 2>/dev/null; then
    echo -n "Installing rbenv and ruby ${ruby_version}... " >&3
    brew install rbenv
    brew install ruby-build
    PATH=~/.rbenv/shims:~/.rbenv/bin:$PATH
    rbenv install $ruby_version
    rbenv global $ruby_version
    rbenv rehash
    echo 'complete.' >&3
fi

# installs bundler
if ! gem list -i bundler >/dev/null; then
    echo -n 'Installing bundler... ' >&3
    gem install --no-rdoc --no-ri bundler
    rbenv rehash
    echo 'complete.' >&3
fi

# installs gems
cd $dir
bundle install >&3

# closes file descriptor and restores working directory
exec 3>&-
cd $old_dir

# reloads bashrc
source ~/.bashrc
