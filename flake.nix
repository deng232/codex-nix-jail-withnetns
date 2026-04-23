{
  description = "codex-nix-jail-withnetns";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    jail-nix = {
      url = "git+https://git.sr.ht/~alexdavid/jail.nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, jail-nix }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          jail-lib = import jail-nix { };
          jail = jail-lib.init pkgs;
          jailed-tools = import ./jail.nix { inherit pkgs jail; };
        in
        {
          default = jailed-tools;
          inherit jailed-tools;
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/jailed-codex";
        };
        jailed-env = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/jailed-env";
        };
        jailed-codex = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/jailed-codex";
        };
      });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        });
    };
}
