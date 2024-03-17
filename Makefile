.PHONY: init
init:
	nix profile install --refresh ./envs

.PHONY: initroot
initroot:
	nix profile install --refresh ./envs#rootonly
.PHONY: init-pure
init-pure:
	nix profile install ./envs#pure

.PHONY: initnix
initnix:
	sudo nixos-rebuild switch --flake ./envs#nixos

.PHONY: init-proxy
init-proxy:
	nix profile install ./envs#proxy

.PHONY: uninstallall
uninstallall:
	nix profile remove ".*"

.PHONY: install
install:
	if git status --porcelain | grep '^??'; then echo 'Please git add your untracked files.'; exit 1; else nix flake update --flake ./envs/flake.nix && nix profile upgrade -L --refresh --all; fi

.PHONY: update
update:
	nix flake update --flake ./envs



.PHONY: i
i:
	make install

.PHONY: debug
debug:
	nix-build ./envs/debug.nix

#	 nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin

.PHONY: gc
gc:
	nix-collect-garbage -d
.PHONY: devworker
devworker:
	wrangler dev ~/.config/sslocal/worker.js

.PHONY: upgrade
upgrade:
	./envs/upgrade.sh
