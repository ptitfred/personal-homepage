.PHONY:
lint:
	nix run .#lint

.PHONY:
local:
	nix run .#local

.PHONY:
tests:
	nix run .#tests
