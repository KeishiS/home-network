# README

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

## デプロイ方法 : colmenaの場合

```
cd colmena
colmena build
colmena apply
```

## LDAPについて

現在は `glauth` を使っているが， `kanidm` も候補だった．もっとやりたい事が複雑になったら考える．

## gpgについて

`nixos-sandi-lenovo` については改善したが，ssh経由でgpg鍵が使えない事象がある．
lenovoでは，gpg-agent関連について，すべてmaskされていたので，全部unmaskしたら改善した．
これを明示的に `configuration.nix` に残したい．