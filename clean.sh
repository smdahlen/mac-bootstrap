#!/usr/bin/env bash

#
# Cleans up resources provisioned by bootstrap.sh.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)

# cleans git repository of untracked and ignored files
cd $dir
git clean -fdx

# removes rbenv
rm -rf ~/.rbenv

# removes homebrew
# TODO: remove bash line in /etc/shells
rm -rf /usr/local/{,.git}*
sudo sed -in '/^\/usr\/local/d' /etc/shells

# removes personal dotfiles
rm -rf $(find ~ -lname "${HOME}/.homesick/*")
rm -rf ~/.homesick

cd $old_dir

unset old_dir dir
