# codex-nix-jail-withnetns
try to isolate ai agent without sudo or cap_sys_admin in delcartive.

create ns fd requre sudo or cap_sys_admin
nsenter require sudo
shell process can't do namespacing as it can only fork process.
