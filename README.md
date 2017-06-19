EC-CUBEのレポジトリに composer update の pull requestを投げるスクリプトです

## 使い方

```
export GITHUB_USER=xxx
export GITHUB_TOKEN=xxx
export GITHUB_USER_EMAIL=xxx@example.com
sh pull-request.sh
```

- EC-CUBEのレポジトリは事前にforkしておく必要があります
- `GITHUB_TOKEN`はGitHubの`Personal access tokens`で事前に発行しておく必要があります

## Travis-CI

Travis-CIのcronで週1回実行しています

https://travis-ci.org/chihiro-adachi/eccube-composer
