#!/bin/bash

set -e
set +x

export GPG_TTY=$(tty)

# setup the gpg-agent to allow presetting a password and enable caching
mkdir -p ~/.gnupg
echo "allow-preset-passphrase" > ~/.gnupg/gpg-agent.conf
echo "default-cache-ttl 120" >> ~/.gnupg/gpg-agent.conf
echo "max-cache-ttl 240" >> ~/.gnupg/gpg-agent.conf

chown -R $(whoami) ~/.gnupg
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.gnupg -type f -exec chmod 600 {} \;

echo "gpg agent config updated"

gpgconf --reload gpg-agent

echo "$GPG_PUBLIC_KEY" > public.key
gpg --import public.key
rm public.key
echo "Public key imported"

echo "$GPG_PRIVATE_KEY" > private.key
gpg --import --batch private.key
rm private.key
echo "Private key imported"

secret_keys=$(gpg --list-secret-keys --with-colons "$GPG_USERNAME <$GPG_EMAIL>")

# labeled as "fpr" 
gpg_fingerprint=$(echo "$secret_keys" | grep "fpr:" | head -n 1 | awk -F "fpr:*" '{print $2}' | awk -F ":" '{print $1}')
echo "${gpg_fingerprint}:6:" > ownertrust.txt
gpg --import-ownertrust < ownertrust.txt
rm ownertrust.txt
echo "Ownertrust updated"

gpg_secret_keyline=$(echo "$secret_keys" | grep "sec")

IFS=":" read -ra gpg_secret_key_details <<< "$gpg_secret_keyline"
gpg_secret_keyid="${gpg_secret_key_details[5]}"
# git setup
git config --global user.email "$GPG_EMAIL"
git config --global user.name "$GPG_USERNAME"
git config --global commit.gpgSign true
# git config --global user.signingkey ${gpg_secret_keyid}
echo "Git configured"

# labeled as "grp"
gpg_keygrip=$(echo "$secret_keys" | grep "grp:" | head -n 1 | awk -F "grp:*" '{print $2}' | awk -F ":" '{print $1}')

/usr/lib/gnupg2/gpg-preset-passphrase -c $gpg_keygrip <<< $GPG_PASSPHRASE
echo "Passphrase preset"