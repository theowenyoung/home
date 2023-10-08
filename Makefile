.PHONY: install
install:
	 nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin

.PHONY: gc
gc:
	nix-collect-garbage -d
