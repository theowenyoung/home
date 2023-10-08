{ system
, pkgs
, lib
, flake
, ...
}:

rec {
  find = type: dir:
    let
      contents = builtins.readDir dir;
      filtered = lib.attrsets.filterAttrs (k: v: v == type) contents;
    in
    lib.attrsets.mapAttrsToList (k: v: k) filtered;

  subdirs = find "directory";

  files = find "regular";

  # create overlays from custom packages and include any actual overlays
  overlays =
    let
      packages = subdirs ./packages;
      overlays = subdirs ./overlays;
    in
    lib.lists.forEach packages (p: self: super: { ${p} = pkgs.callPackage ./packages/${p} { }; }) ++
    lib.lists.forEach overlays (o: import ./overlays/${o});

  modules = lib.lists.forEach (files ./modules) (m: ./modules/${m});

  homedir = username: (if pkgs.stdenv.isLinux then "/home" else "/Users") + "/${username}";

  activationScripts = scripts:
    let
      run = script: lib.hm.dag.entryAfter [
        "installPackages"
        "onFilesChange"
        "reloadSystemd"
      ] ''
        # can't use config.home.path so rely on .nix-profile
        export PATH="/bin:/usr/bin:$HOME/.nix-profile/bin:$PATH"
        if [ -n "$DRY_RUN_CMD" ]; then
          if [ -r "${script}" ]; then
            head -n3 "${script}"
          else
            echo '${script}' | head -n3
          fi
          echo ${flake}
        else
          ${script}
        fi
      '';

      # if the given script is one line, use that as the name of the activation
      # entry. otherwise, hash the arbitrary script content to get a name.
      # prepend an index so the scripts run in the same order as they're defined
      # in the list (nix sorts the entries)
      condense = i: script: {
        value = run script;
        name =
          let
            fname =
              if (lib.strings.hasInfix "\n" script)
              then builtins.hashString "md5" script
              else script;
          in
          "[${toString i}] ${fname}";
      };
    in
    builtins.listToAttrs (lib.lists.imap0 condense scripts);
}
