.PHONY: init
init:
	nix profile install ./.config/env

.PHONY: init-pure
init-pure:
	nix profile install ./.config/env#pure


.PHONY: init-proxy
init-proxy:
	nix profile install ./.config/env#proxy

.PHONY: clean
clean:
	nix profile remove 0

.PHONY: install
install:
	if git status --porcelain | grep '^??'; then echo 'Please git add your untracked files.'; exit 1; else 	nix profile upgrade --refresh --verbose  '.*'; fi


.PHONY: i
i:
	make install

.PHONY: debug
debug:
	nix-build ./.config/env/debug.nix

#	 nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin

.PHONY: gc
gc:
	nix-collect-garbage -d
