#!/bin/bash

#
# Cleans up resources provisioned by bootstrap.sh.
#


dir=$(cd "$(dirname "$0")" && pwd)

sudo -v

# removes chef
sudo rm -rf $(find /usr/bin -lname '/opt/chef/*')
sudo rm -rf /opt/chef

# removes rbenv
rm -rf ~/.rbenv

# removes homebrew
# TODO: move into a cookbook since it was not provisioned with bootstrap.sh
rm -rf /usr/local/{,.git}*

# cleans git repository of untracked and ignored files
cd $dir
git clean -fdx
