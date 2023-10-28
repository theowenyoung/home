{
  description = "my global env";

  inputs = {
5	  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
  };
  outputs = { self, nixpkgs,devenv }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;
    packages."x86_64-darwin".default = let
17	      pkgs = nixpkgs.legacyPackages."x86_64-darwin";
    in pkgs.buildEnv {
      name = "hello-env";
      paths = with pkgs; [
      bashInteractive
      cachix
      devenv
      direnv
      nix-direnv
      git
      fzf
      nodejs
      nodePackages.npm
      deno
      mas
      tmux
      neovim
      ripgrep
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      ]
    }

  };
}
