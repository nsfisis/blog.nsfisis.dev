---
title: "[備忘録] このサイト用の VPS をセットアップしたときのメモ"
date: 2022-10-28T21:55:23+09:00
draft: false
tags: ["note-to-self"]
summary: |
  GitHub Pages でホストしていたこのサイトを VPS へ移行したので、
  そのときにやったことのメモ。99 % 自分用。
changelog:
  2022-10-28: 公開
---



# はじめに

これまでこの blog は GitHub Pages でホストしていたのだが、先日 VPS に移行した。そのときにおこなったサーバのセットアップ作業を書き残しておく。99 % 自分用の備忘録。別のベンダに移したりしたくなったら見に来る。

未来の自分へ: 特に自動化してないので、せいぜい苦しんでくれ。



# VPS

[さくらの VPS](https://vps.sakura.ad.jp/) の 2 GB プラン。そこまで真面目に選定していないので、困ったら移動するかも。



# 事前準備

## サーバのホスト名を決める

モチベーションが上がるという効能がある。今回は藤原定家から取って "teika" にした。たいていいつも源氏物語の帖か小倉百人一首の歌人から選んでいる。

## SSH の鍵生成

ローカルマシンで鍵を生成する。

```shell-session
$ ssh-keygen -t ed25519 -b 521 -f ~/.ssh/teika.key
$ ssh-keygen -t ed25519 -b 521 -f ~/.ssh/github2teika.key
```

`teika.key` はローカルからサーバへの接続用、`github2teika.key` は、GitHub Actions からサーバへのデプロイ用。

## SSH の設定

`.ssh/config` に設定しておく。

```ssh_config
Host teika
    HostName **********
    User **********
    Port **********
    IdentityFile ~/.ssh/teika.key
```


# 基本のセットアップ

## SSH 接続

VPS 契約時に設定した管理者ユーザとパスワードを使ってログインする。

## ユーザを作成する

管理者ユーザで作業すると危ないので、メインで使うユーザを作成する。`sudo` グループに追加して `sudo` できるようにし、`su` で切り替え。

```shell-session
$ sudo adduser **********
$ sudo adduser ********** sudo
$ su **********
$ cd
```

## ホスト名を変える

```shell-session
$ sudo hostname teika
```

## 公開鍵を置く

```shell-session
$ mkdir ~/.ssh
$ chmod 700 ~/.ssh
$ vi ~/.ssh/authorized_keys
```

`authorized_keys` には、ローカルで生成した `~/.ssh/teika.key.pub` と `~/.ssh/github2teika.key.pub` の内容をコピーする。

## SSH の設定

SSH の設定を変更し、少しでも安全にしておく。

```shell-session
$ sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
$ sudo vi /etc/ssh/sshd_config
```

* `Port` を変更
* `PermitRootLogin` を `no` に
* `PasswordAuthentication` を `no` に

そして設定を反映。

```shell-session
$ sudo systemctl restart sshd
$ sudo systemctl status sshd
```

## SSH で接続確認

今の SSH セッションは閉じずに、ターミナルを別途開いて疎通確認する。セッションを閉じてしまうと、SSH の設定に不備があった場合に締め出しをくらう。

```shell-session
$ ssh teika
```

## ポートの遮断

デフォルトの 22 番を閉じ、設定したポートだけ空ける。

```shell-session
$ sudo ufw deny ssh
$ sudo ufw allow *******
$ sudo ufw enable
$ sudo ufw reload
$ sudo ufw status
```

ここでもう一度 SSH の接続確認を挟む。

## GitHub 用の SSH 鍵

GitHub に置いてある private リポジトリをサーバから clone したいので、SSH 鍵を生成して置いておく。

```shell-session
$ ssh-keygen -t ed25519 -b 521 -f ~/.ssh/github.key
$ cat ~/.ssh/github.key.pub
```

[GitHub の設定画面](https://github.com/settings/ssh) から、この公開鍵を追加する。

```shell-session
$ vi ~/.ssh/config
```

設定はこう。

```ssh_config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github.key
```

最後に接続できるか確認しておく。

```shell-session
ssh -T github.com
```

## パッケージの更新

```shell-session
$ sudo apt update
$ sudo apt upgrade
$ sudo apt update
$ sudo apt upgrade
$ sudo apt autoremove
```


# サイトホスティング用のセットアップ

## DNS に IP アドレスを登録する

このサーバは固定の IP アドレスがあるので、`A` レコードに直接入れるだけで済んだ。

## 使うソフトウェアのインストール

```shell-session
$ sudo apt install docker docker-compose git make
```

## メインユーザが Docker を使えるように

```shell-session
sudo adduser ********** docker
```

## HTTP/HTTPS を通す

80 番と 443 番を空ける。

```shell-session
$ sudo ufw allow 80/tcp
$ sudo ufw allow 443/tcp
$ sudo ufw reload
$ sudo ufw status
```

## リポジトリのクローン

```shell-session
$ cd
$ git clone git@github.com:nsfisis/nsfisis.dev.git
$ cd nsfisis.dev
$ git submodule update --init
```

## certbot で証明書取得

```shell-session
$ docker-compose up -d acme-challenge
$ make setup
```

## サーバを稼動させる

```shell-session
$ make serve
```



# 感想

(業務でなく) 個人だと数年ぶりのサーバセットアップで、これだけでも割と時間を食ってしまった。とはいえ式年遷宮は楽しいので、これからも定期的にやっていきたい。コンテナデプロイにしたい気持ちもあるのだが、色々実験したい関係上、本物のサーバも欲しくはある。次の式年遷宮では、手順の一部だけでも自動化したいところ。
