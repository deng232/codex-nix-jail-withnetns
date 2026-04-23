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

## TODO

Figure out how podman handles persistent files without mount fd.
