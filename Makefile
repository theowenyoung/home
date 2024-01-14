.PHONY: init
init:
	nix profile install --refresh ./envs

.PHONY: init-pure
init-pure:
	nix profile install ./envs#pure


.PHONY: init-proxy
init-proxy:
	nix profile install ./envs#proxy

.PHONY: uninstallall
uninstallall:
	nix profile remove 0

.PHONY: install
install:
	if git status --porcelain | grep '^??'; then echo 'Please git add your untracked files.'; exit 1; else 	nix profile upgrade -L --refresh --verbose  '.*'; fi

.PHONY: update
update:
	nix flake update ./envs



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
