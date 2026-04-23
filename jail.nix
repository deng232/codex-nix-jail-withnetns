{
  pkgs ? import <nixpkgs> { },
  jail,
}:
let
  codexProfile = pkgs.buildEnv {
    name = "codex-env-profile";
    paths = with pkgs; [
      codex
      bashInteractive
      zsh
      git
      coreutils
      findutils
      gnugrep
      gnused
      gawk
      curl
    ];
    ignoreCollisions = true;
  };

  mkJail = name: program: argv:
    jail name program (
      c: with c; [
        mount-cwd

        # Nix profile is a symlink tree; the store must be visible too.
        (readonly "/nix/store")
        (readonly codexProfile)

        (set-env "PATH" "${codexProfile}/bin")
        (set-env "HOME" "/tmp")
        (set-env "SHELL" program)
        network
        (add-runtime "export BROWSER=firefox")
        open-urls-in-browser
        (set-argv argv)
      ]
    );

  jailed-env-inner = mkJail "jailed-env" "${pkgs.bashInteractive}/bin/bash" [ "-i" ];
  jailed-codex-inner = mkJail "jailed-codex" "${pkgs.zsh}/bin/zsh" [ "-i" "-c" "codex" ];

  mkRootlessRunner = name: innerDrv:
    pkgs.writeShellScriptBin name ''
      exec ${pkgs.rootlesskit}/bin/rootlesskit \
        --net=slirp4netns \
        --slirp4netns-binary ${pkgs.slirp4netns}/bin/slirp4netns \
        --port-driver=builtin \
        -p 127.0.0.1:1455:1455/tcp \
        ${innerDrv}/bin/${name}
    '';

  jailed-env = mkRootlessRunner "jailed-env" jailed-env-inner;
  jailed-codex = mkRootlessRunner "jailed-codex" jailed-codex-inner;
in
pkgs.symlinkJoin {
  name = "jailed-tools";
  paths = [ jailed-env jailed-codex ];
}
