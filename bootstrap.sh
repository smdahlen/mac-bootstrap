#!/bin/bash

#
# Bootstraps a mac by installing homebrew, chef, rbenv, and berkself.
# After the minimal tools are installed, chef-solo provisions specified recipes
# in dna.json using cookbooks listed in Berksfile.
#


dir=$(cd "$(dirname "$0")" && pwd)
ruby_version='1.9.3-p385'

# redirects standard and error output to log file
exec 3>&1 1>$dir/bootstrap.log 2>&1

# starts sudo keepalive described at https://gist.github.com/cowboy/3118588
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 $$ | exit
done 2>/dev/null &

# installs homebrew
echo -n 'Installing homebrew... ' >&3
if ! [ -e /usr/local/bin/brew ]; then
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)" </dev/null
fi
echo 'complete.' >&3

# installs chef
echo -n 'Installing chef... ' >&3
if ! [ -d /opt/chef ]; then
    curl -L https://www.opscode.com/chef/install.sh | sudo bash
    cd $dir
    mkdir -p chef/{cookbooks,cache}
fi
echo 'complete.' >&3

# installs rbenv and the specified ruby version
echo -n "Installing rbenv and ruby ${ruby_version}... " >&3
if ! which rbenv 2>/dev/null; then
    brew install rbenv
    brew install ruby-build
    PATH=~/.rbenv/{shims,bin}:$PATH
    rbenv install $ruby_version
    rbenv global $ruby_version
    rbenv rehash
fi
echo 'complete.' >&3

# installs berkshelf and vendors cookbooks
echo -n 'Installing berkshelf and vendoring cookbooks... ' >&3
gem install --no-rdoc --no-ri berkshelf
rbenv rehash
cd $dir
berks install --path $dir/chef/cookbooks
echo 'complete.' >&3

# provisions cookbooks with chef-solo
echo -n 'Provisioning cookbooks with chef-solo... ' >&3
chef-solo -c $dir/solo.rb -j $dir/dna.json
echo 'complete.' >&3

# closes file descriptor
exec 3>&-
