#!/bin/sh
#set -x

# Work directory of this repository.
if [ "$1" != "" ]; then
    workdir=$1
else
    workdir=.
fi

cd $workdir
if [ ! -f .travis.yml ]; then
    echo "Wrong directory."
    exit 1
fi

# older git does not know about --no-edit for git-pull
# e.g. 1.7.9.5
# git pull --no-edit
git pull

if [ ! -d neovim/src ]; then
    git submodule init
fi
git submodule update

# Get the latest vim source code
cd neovim
vimoldver=$(git rev-parse HEAD)
git checkout nightly
git pull
vimnewver=$(git rev-parse HEAD)
vimtag=$(git describe --tags --abbrev=0)
cd -

curdate=$(date "+%F")

# Check if it is updated
if git diff --exit-code > /dev/null; then
    echo "No changes found."
    exit 0
fi

# Commit the change and push it
git commit -a -m "Neovim: $vimnewver"
git tag "$curdate"
git push origin master --tags
