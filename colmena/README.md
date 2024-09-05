```
zfs create -o mountpoint=legacy pool0/nfs
```

portunusのユーザでのsshアクセスは，portunusにssh鍵を登録してもできないため，
通常通りホームディレクトリ下の `.ssh/authorized_keys` に登録が必要
