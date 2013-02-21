#!/bin/bash

#
# Cleans up resources provisioned by bootstrap.sh.
#

old_dir=$PWD
dir=$(cd "$(dirname "$0")" && pwd)

cd $dir

# removes rbenv
rm -rf ~/.rbenv

# removes homebrew
rm -rf /usr/local/{,.git}*

# removes personal dotfiles
rm -rf ../dotfiles

# cleans git repository of untracked and ignored files
git clean -fdx

cd $old_dir
