#!/bin/sh

if [ "$SSH_ORIGINAL_COMMAND" = "git-receive-pack '/mnt/usb/pass/.git'" ]; then
  git-receive-pack '/mnt/usb/pass/.git'
elif [ "$SSH_ORIGINAL_COMMAND" = "git-upload-pack '/mnt/usb/pass/.git'" ]; then
  git-upload-pack '/mnt/usb/pass/.git'
else
  exit 1
fi
