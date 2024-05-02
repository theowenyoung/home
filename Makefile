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
