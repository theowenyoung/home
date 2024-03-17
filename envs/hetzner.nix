{modulesPath, ...}: {
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

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    extraConfig = ''
      PrintLastLog no
    '';
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # FIXME: MAKE SURE YOU UPDATE THE ID_RSA.PUB FILE
    # Generally you should be able to do "cp ~/.ssh/id_rsa.pub ."
    (builtins.readFile ./id_rsa.pub)
  ];
}
