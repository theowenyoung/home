#!/bin/sh
set -eu

# As our home directory on any new machine will likely be non-empty, "cloning"
# this project involves manually initiliazing a new Git repo and setting up the
# remotes ourselves (fetch over HTTPS and push over SSH). The hard reset removes
# any conflicting files.

cd "$HOME"
rm -rf .git
git init
git remote add origin https://github.com/theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
git remote set-url --push origin git@github.com:theowenyoung/home.git
git remote -v