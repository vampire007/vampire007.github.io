# 当前仓库使用指定的公钥
假定在目录 /Users/andy_mm/andy/ssh 存放了公钥和私钥
```sh
git config core.sshCommand "ssh -i /Users/andy_mm/andy/ssh/id_rsa -F /dev/null"
```