{
  pkgs ? import <nixpkgs> { },
}:
let
  jail-nix = import (builtins.fetchGit {
    url = "https://git.sr.ht/~alexdavid/jail.nix";
    #      rev = "42b355c38ca63dab4904acc5c0d95f17954a8c9b";
    ref = "main";
  }) { };
  jail = jail-nix.init pkgs;
  jailed-tools = import ./jail.nix { inherit jail pkgs; };
in

pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } {
  packages = with pkgs; [
    clang
    meson
    ninja
    pkg-config
    gdb
    libcap
    libseccomp
    cmake
    libselinux
    libxslt
    bash-completion
    jailed-tools
    slirp4netns
  ];

  shellHook = ''
    export CC=clang
    export CXX=clang++
    echo "Meson dev shell ready"
    echo "Run: meson setup build && meson compile -C build"
  '';
}
