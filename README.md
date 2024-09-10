# README

This repository contains server settings for my home PC network.
The network consists of 3 PCs:
* ThinkCentre M75q-1 Tiny
* Raspberry Pi4
* Mini PC equipped with an Intel N100 processor

All PCs are running [NixOS](https://nixos.org/) and primarily host the following services:
* NFS
* LDAP

In addition to these services, I utilize these PCs as worker nodes for distributed computing tasks.

## How to Deploy

Before deploying, some preliminary steps are required to access private information:
* Place an access token in your home directory
* Reorganize the storage partitions to match the config file

Once the prerequisites are in place, deploy using the following commands:
```
colmena build && colmena apply
```

## About LDAP

I chose [`Portunus`](https://github.com/majewsky/portunus) because OpenLDAP is too complicated for me.
Other options considered were:
* `glauth`
* `kanidm`

```
openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp521r1 -out key.pem
# 中身の確認は以下のコマンド
openssl ec -text -noout -in key.pem
# 自己署名証明書なので，CSRの生成はすっ飛ばして証明書を出力
openssl req -new -x509 -days 365 -key key.pem -sha512 -out serv.crt -subj "/C=JP/ST=Tokyo/L=Tachikawa/CN=localhost" -addext "subjectAltName=DNS:localhost,IP:192.168.10.25"
```
