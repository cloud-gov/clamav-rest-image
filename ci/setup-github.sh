#!/bin/bash

set -e
set +x
echo "$GH_SSH_PRIVATE_KEY" > ssh.key
set -x
chmod 600 ssh.key
eval "$(ssh-agent -s)"
ssh-add ssh.key

mkdir -p ~/.ssh
ssh-keyscan -t rsa -H github.com >> ~/.ssh/known_hosts 