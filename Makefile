.PHONY: init
init:
	nix profile install ./.config/env

.PHONY: init-pure
init-pure:
	nix profile install ./.config/env#pure


.PHONY: install
install:
	nix profile upgrade '.*'

#	 nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin

.PHONY: gc
gc:
	nix-collect-garbage -d
