#!/usr/bin/env bash

#
# Bootstraps a mac by installing homebrew, common tools, personal dotfiles,
# and an updated ruby environment.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)
ruby_version='1.9.3-p385'

# redirects standard and error output to log file
exec 3>&1 1>$dir/bootstrap.log 2>&1

# starts sudo keepalive as described at https://gist.github.com/cowboy/3118588
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# installs homebrew
if ! [ -e /usr/local/bin/brew ]; then
    echo -n 'Installing homebrew... ' >&3
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" </dev/null
    echo 'complete.' >&3
fi

# installs common tools
# TODO: fix sudo password prompt (subshell issue?)
if ! hash irssi 2>/dev/null; then
    echo -n 'Installing common tools... ' >&3
    brew install bash mercurial vim git bash-completion irssi
    if ! grep "^$(brew --prefix)/bin/bash" /etc/shells >/dev/null; then
        echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells >/dev/null
    fi
    echo 'complete.' >&3
    echo 'Update shell by running chsh -s /usr/local/bin/bash' >&3
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
rbenv rehash

# installs personal dotfiles
if ! [ -d ~/.homesick ]; then
    echo -n 'Installing personal dotfiles... ' >&3
    homesick clone smdahlen/dotfiles
    homesick symlink smdahlen/dotfiles
    echo 'complete.' >&3
fi

# closes file descriptor and restores working directory
exec 3>&-
cd $old_dir

unset dir old_dir ruby_version
