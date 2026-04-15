{
  pkgs ? import <nixpkgs> { },
  jail,
}:
let
  codexProfile = pkgs.buildEnv {
    name = "codex-env-profile";
    paths = with pkgs; [
      codex
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

  jail-env = jail "codex-env" "${pkgs.zsh}/bin/zsh" (
    c: with c; [
      mount-cwd

      # Nix profile is a symlink tree; the store must be visible too.
      (readonly "/nix/store")
      (readonly codexProfile)

      (set-env "PATH" "${codexProfile}/bin")
      (set-env "HOME" "/tmp")
      (set-env "SHELL" "${pkgs.zsh}/bin/zsh")
      network
      (add-runtime "export BROWSER=firefox")
      #(set-env "BROWSER" "${firefox}/bin/firefox")
      open-urls-in-browser # don't work with rootlesskit, firefox login callback can't connect to localhost:{xxx}
      # If your jail DSL supports argv only:
      (set-argv [ "-i" ])
    ]
  );

  codex-jail-netns = pkgs.writeShellScriptBin "codex-env" ''
    exec ${pkgs.rootlesskit}/bin/rootlesskit \
      --net=slirp4netns \
      ${jail-env}/bin/codex-env
  '';
in
#jail-env
codex-jail-netns
