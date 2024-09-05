# README

## How to Deploy

```
colmena build
colmena apply
```

## LDAPについて

最終的には `portunus` を採用

portunusのユーザでのsshアクセスは，portunusにssh鍵を登録してもできないため，
通常通りホームディレクトリ下の `.ssh/authorized_keys` に登録が必要．ホームディレクトリ下に置かずにSSH認証するには `AuthorizedKeysCommand` のための適当なスクリプトを作成する必要がある．

## zfsの設定について

```
zfs create -o mountpoint=legacy pool0/nfs
```

## remote serverでgpg鍵を使うための準備

remote serverの `sshd_config` に以下を追記

```
AllowAgentForwarding yes
StreamLocalBindUnlink yes
```

GPGの公開鍵束をremote serverへインポート

```
gpg --export --armor <ID> | ssh <REMOTE> gpg --import
```

local hostの `.ssh/config` に `IdentityAgent ..., RemoteForward ..., ForwardAgent yes` を追記
