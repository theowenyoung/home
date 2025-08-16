# source env below
# source ~/.secrets


HOST='root@${K3S_HOST}'
serverip := $(IP)
# Remote user
ruser := $(or $(RUSER), root)


.PHONY: setupansible
setupansible:
	ansible-galaxy install -r ./deploy/ansible/requirements.yml
	ansible-galaxy collection install -r ./deploy/ansible/requirements.yml
# 语法检查
.PHONY: checkansible
checkansible:
	ansible-playbook playbooks/site.yml --syntax-check
# IP=xxx make serverinstall
.PHONY: installserver
installserver:
ifndef IP
	$(error IP is not set. Usage:  IP=192.168.1.100 make serverinstall)
endif
	rsync -chazP deploy/ansible/init.sh $(ruser)@$(serverip):
	ssh $(ruser)@$(serverip) './init.sh'


.PHONY: initserver
initserver:
	make setupansible
	# ansible-playbook deploy/ansible/init/init.yaml -i deploy/ansible/init/inventory.ini --ask-pass

.PHONY: bootstrapserver
bootstrapserver:
	make setupansible
	ansible-playbook deploy/ansible/playbooks/bootstrap.yml -i deploy/ansible/inventory.ini --ask-pass -u root

.PHONY: initserverwithoutpass
initserverwithoutpass:
	ansible-playbook deploy/ansible/init/init.yaml -i deploy/ansible/init/inventory.ini
	uc machine init deploy@deploy1
.PHONY: deployserver
deployserver:
	ansible-playbook deploy/ansible/playbook.yaml -i deploy/ansible/inventory.ini

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
	if git status --porcelain | grep '^??'; then echo 'Please git add your untracked files.'; exit 1; else nix profile upgrade -L --refresh --all --impure; fi

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


.PHONY: testremote
testremote:
	ssh ${HOST} 'apt-get update'


.PHONY: kubernetes_install
kubernetes_install:
	ssh ${HOST} 'export INSTALL_K3S_EXEC="--disable traefik"; curl -sfL https://get.k3s.io | sh -'

.PHONY: initremote
initremote:
	ssh ${HOST} 'apt-get update && apt-get install -y curl htop mtr tcpdump ncdu vim dnsutils strace iftop'
	ssh ${HOST} 'echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | debconf-set-selections && apt-get install unattended-upgrades -y'
	make kubernetes_install



.PHONY: initlocalk3s

initlocalk3s:
	# sops -d --extract '["public_key"]' --output ~/.ssh/id_ed25519_deploy.pub deploy/secrets/ssh.yml
	# sops -d --extract '["private_key"]' --output ~/.ssh/id_ed25519_deploy deploy/secrets/ssh.yml
	# chmod 600 ~/.ssh/id_ed25519_deploy.*
	# grep -q erebe.eu ~/.ssh/config > /dev/null 2>&1 || cat config/ssh_client_config >> ~/.ssh/config
	mkdir -p ~/.kube || exit 0
	sops -d --output ~/.kube/config deploy/secrets/k3s.yml
	chmod 600 ~/.kube/config

.PHONY: inittraefik
inittraefik:
	helm repo add traefik https://helm.traefik.io/traefik
	helm repo update

.PHONY: installtraefik
installtraefik:
	helm install traefik ~/deploy/traefik --values ~/deploy/traefik/values.yml --debug
.PHONY: uninstallmeili
uninstallmeili:
	helm uninstall meili

.PHONY: uninstalltraefik
uninstalltraefik:
	helm uninstall traefik
.PHONY: upgradetraefik
upgradetraefik:
	helm upgrade traefik ~/deploy/traefik --values ~/deploy/traefik/values.yml --debug

.PHONY: initmeili
initmeili:
	helm repo add meilisearch https://meilisearch.github.io/meilisearch-kubernetes
	helm repo update
	helm dependency build deploy/meilisearch


.PHONY: installmeili
installmeili:
	sops exec-env deploy/meilisearch/sops_secrets.yml 'helm install meili ~/deploy/meilisearch --set meilisearch.environment.MEILI_MASTER_KEY="$${MEILI_MASTER_KEY}" -f ~/deploy/meilisearch/values.yml --debug'

.PHONY: upgrademeili
upgrademeili:
	sops exec-env deploy/meilisearch/sops_secrets.yml 'helm upgrade meili ~/deploy/meilisearch --set meilisearch.environment.MEILI_MASTER_KEY="$${MEILI_MASTER_KEY}" -f ~/deploy/meilisearch/values.yml --debug'

.PHONY: logstraefik
logstraefik:
	kubectl logs -f -l app=traefik
.PHONY: logscaddy
logscaddy:
	kubectl logs -f -l app=caddy
.PHONY: logsmeili
logsmeili:
	kubectl logs -f -l app=meilisearch

.PHONY: installdirectus
installdirectus:
	sops exec-env deploy/directus/sops_secrets.yml 'cat ./deploy/directus/manifest.yaml | envsubst | kubectl apply -f -'

.PHONY: installredis
installredis:
	kubectl apply -f deploy/redis/manifest.yaml

.PHONY: logsdirectus
logsdirectus:
	kubectl logs -f -l app=directus

.PHONY: installmariadb
installmariadb:
	sops exec-env deploy/mariadb/sops_secrets.yml 'cat ./deploy/mariadb/manifest.yaml | envsubst | kubectl apply -f -'
.PHONY: logsmariadb
logsmariadb:
	kubectl logs -f -l app=mariadb

.PHONY: job
job:
	sops exec-env deploy/mariadb/sops_secrets.yml 'cat ./deploy/jobs/2024-06-18-create-db.yaml | envsubst | kubectl apply -f -'
.PHONY: logsjob
logsjob:
	kubectl logs -f -l app=job

.PHONY: installread
installread:
	sops exec-env deploy/read/sops_secrets.yml 'cat ./deploy/read/manifest.yaml | envsubst | kubectl apply -f -'
.PHONY: logsread
logsread:
	kubectl logs -f -l app=read
.PHONY: forcerestart
forcerestart:
	kubectl rollout restart deployment/read-deployment


.PHONY: installcaddy
installcaddy:
	kubectl apply -f deploy/caddy/manifest.yaml
.PHONY: upgradecaddy
upgradecaddy:
	kubectl rollout restart deployment --selector app=caddy

.PHONY: installv2ray
installv2ray:
	sops exec-env deploy/v2ray/sops_secrets.yml 'cat ./deploy/v2ray/manifest.yaml | envsubst | kubectl apply -f -'

.PHONY: upgradev2ray
upgradev2ray:
	kubectl rollout restart deployment --selector app=v2ray
