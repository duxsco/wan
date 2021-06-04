#!/bin/sh

if [ "$SSH_ORIGINAL_COMMAND" = "git-receive-pack '/mnt/md0/pass/.git'" ]; then
  git-receive-pack '/mnt/md0/pass/.git'
elif [ "$SSH_ORIGINAL_COMMAND" = "git-upload-pack '/mnt/md0/pass/.git'" ]; then
  git-upload-pack '/mnt/md0/pass/.git'
else
  exit 1
fi
