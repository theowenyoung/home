# 导出 .env 文件中的变量
ifneq (,$(wildcard .env))
    include .env
    export $(shell sed 's/=.*//' .env)
endif

HOST='root@${K3S_HOST}'

.PHONY: init
init:
	nix profile install --refresh .

.PHONY: initroot
initroot:
	nix profile install --refresh .#rootonly
.PHONY: init-pure
init-pure:
	nix profile install .#pure

.PHONY: initnix
initnix:
	sudo nixos-rebuild switch --flake .#nixos

.PHONY: init-proxy
init-proxy:
	nix profile install .#proxy

.PHONY: uninstallall
uninstallall:
	nix profile remove ".*"

.PHONY: install
install:
	if git status --porcelain | grep '^??'; then echo 'Please git add your untracked files.'; exit 1; else nix profile upgrade -L --refresh --all; fi

.PHONY: update
update:
	nix flake update --flake .



.PHONY: i
i:
	make install

.PHONY: debug
debug:
	nix-build ./nix/debug.nix

#	 nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin

.PHONY: gc
gc:
	nix-collect-garbage -d
.PHONY: devworker
devworker:
	wrangler dev ~/.config/sslocal/worker.js

.PHONY: upgrade
upgrade:
	./upgrade.sh

.PHONY: initlocalwithk3s

initlocalwithk3s:
	# sops -d --extract '["public_key"]' --output ~/.ssh/id_ed25519_deploy.pub deploy/secrets/ssh.yml
	# sops -d --extract '["private_key"]' --output ~/.ssh/id_ed25519_deploy deploy/secrets/ssh.yml
	# chmod 600 ~/.ssh/id_ed25519_deploy.*
	# grep -q erebe.eu ~/.ssh/config > /dev/null 2>&1 || cat config/ssh_client_config >> ~/.ssh/config
	mkdir ~/.kube || exit 0
	sops -d --output ~/.kube/config deploy/secrets/k3s.yml


.PHONY: test
test:
	ssh ${HOST} 'apt-get update'

.PHONY: initremote
initremote:
	ssh ${HOST} 'apt-get update && apt-get install -y curl htop mtr tcpdump ncdu vim dnsutils strace linux-perf iftop'
	ssh ${HOST} 'echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections && apt-get install unattended-upgrades -y'


.PHONY: kubernetes_install
kubernetes_install:
	ssh ${HOST} 'curl -sfL https://get.k3s.io | sh -'
