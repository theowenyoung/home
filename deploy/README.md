# 个人服务部署

1. 新建一个新的 Debian 服务器，记住 ip
1. 将 `export K3S_HOST=your_ip` 添加到 `~/.secrets` 中
1. `source ~/.secrets`
1. 把本机的 `~/.ssh/id_ed25519.pub` 添加到远程服务器的 `mkdir -p ~/.ssh && echo ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAPcRy9wGjP47bHpv2RcNO3yw3udCcTlgWs22KLcpUW main@example.com >> ~/.ssh/authorized_keys` 中
1. 在远程服务器安装 k3s, `make initremote`, 会自动安装 k3s，还有 `kubectl` 等命令(不需要自带的 Traefik, 我需要自己安装)
1. 本地安装 `kubectl`, `helm`, `sops` 命令, sops 用于管理k3s 的配置
1. 复制远程机器的 `/etc/rancher/k3s/k3s.yaml` 中的内容到 `deploy/secrets/k3s.yml` 中, 执行 `sops deploy/secrets/k3s.yml` 写入，并且修改 server 的地址为远程服务器的地址，这样以后就可以在本地部署了。
1. 复制刚刚的文件到本地的 `~/.kube/config` 中，这样就可以使用 `kubectl` 命令了，执行 `make initlocalk3s`
1. 安装 `traefik`, 执行`make installtraefik`
1. 安装 `meilisearch`, 执行`make installmeili`
1. 安装 `mariadb`, 执行`make installmariadb`
1. 安装 `redis` , 执行`make installredis`

## 授权 github register

更新 `/etc/rancher/k3s/registries.yaml`

```
mirrors:
  ghcr.io:
    endpoint:
      - "https://ghcr.io"
configs:
  "ghcr.io":
    auth:
      username: "theowenyoung"
      # github 中创建一个有package权限的个人token
      password: ""
    tls:
      insecure_skip_verify: false

```

重启k3s `sudo systemctl restart k3s`

## 获取服务器 k3s token

```
cat /var/lib/rancher/k3s/server/node-token
```

## 参考

- [Persion Server](https://github.com/erebe/personal-server)
- [Deploy traefik on kubernetes with helm and let's encrypt certificates](https://ewencodes.github.io/blog/cloud/kubernetes/deploy-traefik-on-kubernetes-with-helm-and-lets-encrypt-certificates/)
