{ modulesPath, config, lib, pkgs, ... }: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.firewall.enable = false;
  services.openssh.enable = true;

  age.secrets.meilisearch.file = ./secrets/meilisearch.age;
  services.meilisearch = {
    enable = true;
    environment = "production";
    listenPort = 7700;
    masterKeyEnvironmentFile = config.age.secrets.passwordfile-meilisearch.path;
  };

  services.nginx = {
    enable = true;
    virtualHosts."meilisearch.owenyoung.com" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:7700/";
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };



  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  users.users.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAPcRy9wGjP47bHpv2RcNO3yw3udCcTlgWs22KLcpUW main@example.com"
  ];

  system.stateVersion = "23.11";
}
