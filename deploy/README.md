# 个人服务部署

## 初始化项目

1. 生成一个部署专用的 ssh key:

```bash
ssh-keygen -t ed25519 -C "main@example.com"
```

记得选择一个不同的位置，比如 `~/.ssh/id_ed25519_deploy`, 并且设置密码

2. 将 ssh 保存在 `deploy/secrets/ssh.yml` 中

```bash
sops deploy/secrets/ssh.yml
```

分别是 `public_key`, `private_key`

3. 在服务器上安装 k3s

```
curl -sfL https://get.k3s.io | sh -
```

4. 把服务器上的 `/etc/rancher/k3s/k3s.yaml` 文件内容，修改 ip 为服务器，然后保存到 `deploy/secrets/k3s.yml` 中

```bash
sops deploy/secrets/k3s.yaml
```

## 服务器初始化

> 安装 Docker

```bash
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl gnupg lsb-release
DISTRO="$(lsb_release -is | tr [:upper:] [:lower:])"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL "https://download.docker.com/linux/${DISTRO}/gpg" |
	sudo gpg --dearmor -o '/etc/apt/keyrings/docker.gpg'

echo "deb [arch=$(dpkg --print-architecture)" \
	'signed-by=/etc/apt/keyrings/docker.gpg]' \
	"https://download.docker.com/linux/${DISTRO}" \
	"$(lsb_release -cs) stable" |
	sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt-get -y update

sudo apt-get -y install \
	docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker swarm init

docker network create --driver overlay traefik-public

```

base 项目提供：

traefik 作为入口，提供 https 服务，同时支持 http 服务，支持自动获取证书。
postgres 作为数据库服务，提供数据存储。
redis 作为缓存服务，提供缓存存储。

## 自动备份到 s3 的服务

其他的为无状态服务。
