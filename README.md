# codex-nix-jail-withnetns

Currently jailed-codex can only do read/write file in pwd,accessing internet; it cann't access any other tools other than defined in the jail.nix

Try to isolate an AI agent without `sudo` or `cap_sys_admin`, and with netns to isolate the networking stack. Bubblewrap only provides either no netns or simple netns unsharing.

`create ns fd` requires `sudo` or `cap_sys_admin`.
`nsenter` requires `sudo`.
A shell process cannot do namespacing on itself because it can only fork child processes.

## Flake usage

This repository exports multiple apps.

- Run default app (`jailed-codex`):

  ```bash
  nix run "github:<owner>/<repo>"
  ```

- Run a specific app when multiple apps are defined:

  ```bash
  nix run "github:<owner>/<repo>#jailed-env"
  nix run "github:<owner>/<repo>#jailed-codex"
  ```

- Inspect which apps are available:

  ```bash
  nix flake show "github:<owner>/<repo>"
  ```

## Use As A Flake Input

If you want to install the wrappers into `environment.systemPackages`, use the exported package instead of `apps`.

```nix flake
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    codex-jail.url = "github:<owner>/<repo>";
  };

```
``` sub module 
{pkgs,...}:let 

jailed-agent = inputs.codex-jail.packages.${pkgs.stdenv.hostPlatform.system}.default;

in {

}

```

This package installs both binaries:

```bash
jailed-env
jailed-codex
```

If you specifically want the `nix run` interface, the same flake also exports `apps.${system}.default`, `apps.${system}.jailed-env`, and `apps.${system}.jailed-codex`.

## TODO

Figure out how podman handles persistent files without mount fd.
