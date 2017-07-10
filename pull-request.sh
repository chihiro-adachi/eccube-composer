#!/bin/bash -xe

HUB=2.2.9

ORIGIN=https://github.com/EC-CUBE/ec-cube.git
REMOTE=https://github.com/${GITHUB_USER}/ec-cube.git
BRANCH=composer-update-`date +%Y%m%d`
TARGET_BRANCH=${TRAVIS_BRANCH}
CLONE_DIR=ec-cube

# 認証情報の設定.
mkdir -p "${HOME}/.config"
set +x
echo "https://${GITHUB_TOKEN}:@github.com" > "${HOME}/.config/git-credential"
echo "github.com:
- oauth_token: ${GITHUB_TOKEN}
  user: ${GITHUB_USER}" > "${HOME}/.config/hub"
unset GITHUB_TOKEN
set -x

# gitの設定.
git config --global user.name  "${GITHUB_USER}"
git config --global user.email "${GITHUB_USER_EMAIL}"
git config --global core.autocrlf "input"
git config --global hub.protocol "https"
git config --global credential.helper "store --file=$HOME/.config/git-credential"

# hubのインストール.
curl -LO "https://github.com/github/hub/releases/download/v$HUB/hub-linux-amd64-$HUB.tgz" || exit 1
tar xvxf "hub-linux-amd64-$HUB.tgz"
export PATH="$PATH:`pwd`/hub-linux-amd64-$HUB/bin"

# レポジトリのclone.
git clone ${ORIGIN} ${CLONE_DIR}
cd ${CLONE_DIR}

git remote add ${GITHUB_USER} ${REMOTE}
git checkout -b ${BRANCH} origin/${TARGET_BRANCH}

# composer更新.
composer install --no-suggest
composer update --no-suggest 2> composer.log
grep "Nothing to install or update" composer.log

# 更新がなければ終了.
if [ $? -eq 0 ]; then
    exit 0
fi

# remoteへpush.
git add composer.lock
git commit -m "composer update"
git push ${GITHUB_USER} ${BRANCH}

# pull requestの送信.
echo "[${TARGET_BRANCH}] composer update `date +%Y-%m-%d`

## composer update
\`\`\`
`cat composer.log`
\`\`\`
## composer show
\`\`\`
`composer show`
\`\`\`
" > pr.log

hub pull-request -F pr.log -b EC-CUBE/ec-cube:${TARGET_BRANCH} ${GITHUB_USER}/ec-cube:${BRANCH}
