#!/bin/bash

#
# Cleans up resources provisioned by bootstrap.sh.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)

# removes rbenv
rm -rf ~/.rbenv

# removes homebrew
rm -rf /usr/local/{,.git}*

# cleans git repository of untracked and ignored files
cd $dir
git clean -fdx

# removes personal dotfiles
rm -rf $(find ~ -lname "$(cd "${dir}/../dotfiles" && pwd)/*")
rm -rf ../dotfiles

hash -r

cd $old_dir
