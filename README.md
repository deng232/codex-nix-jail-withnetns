# codex-nix-jail-withnetns
try to isolate ai agent without sudo or cap_sys_admin in delcartive way; and with netns to isolate networking stack, which bubblewrap only provide either not netns or just unshare netns.

create ns fd requre sudo or cap_sys_admin \
nsenter require sudo \
shell process can't do namespacing as it can only fork process.\


todo, figure out how podman handle persistant file without mount fd.
