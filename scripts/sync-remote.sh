#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <[user@]remote-host:remote-directory>";
  exit 1;
fi

SYNC_CMD="rsync -a --exclude '.git' --exclude '.gitignore' --exclude '.npmignore' --exclude 'node_modules' --exclude '.idea' --exclude 'build' -e ssh . $1";
echo "syncing to ${1}";
eval $SYNC_CMD;
echo "waiting for changes..."
fswatch -0 -e "\.git" -e "\.idea" -e ".*___$" . | while read -d "" event; do
  relpath=$(realpath --relative-to=$(pwd) ${event});
  echo "  update: ${relpath}";
  eval $SYNC_CMD;
done
