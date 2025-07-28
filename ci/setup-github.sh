#!/bin/bash

set -ex

echo "$GITHUB_SSH_PRIVATE_KEY" > ssh.key
chmod 600 ssh.key
eval "$(ssh-agent -s)"
ssh-add ssh.key

mkdir -p ~/.ssh
ssh-keyscan -t rsa -H github.com >> ~/.ssh/known_hosts 