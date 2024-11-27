docker-image:
	nix run .\#images.x86_64-linux.latest.copyToDockerDaemon
push-docker-image:
	nix run .\#images.x86_64-linux.latest.copyToRegistry
