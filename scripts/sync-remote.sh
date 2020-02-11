#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <[user@]remote-host>";
  exit 1;
fi

# remove scriptname and directory "scripts" from absolute script path
PROJECT_FOLDER=$(basename $(dirname $(dirname $(realpath $0))))

TARGET="${1}:/home/essentim/${PROJECT_FOLDER}"

SYNC_CMD="rsync -a --delete --exclude '.git' --exclude '.gitignore' --exclude '.npmignore' --exclude 'node_modules' --exclude '.idea' --exclude 'coverage' -e \"ssh -o PasswordAuthentication=no -o ConnectTimeout=10 \" . $TARGET";
eval $SYNC_CMD;
if [ $? != 0 ]; then
  exit 1;
fi;

echo "syncing to ${TARGET}";
echo "waiting for changes..."
fswatch -0 -e "\.git" -e "\.idea" -e ".*___$" . | while read -d "" event; do
  relpath=$(realpath --relative-to=$(pwd) ${event});
  echo "  update: ${relpath}";
  eval $SYNC_CMD;
done
echo ""
echo "terminated";
exit 0;
