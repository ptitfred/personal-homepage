lint:
	nix run .#lint

dev-server:
	nix run .#dev-server -- website

local:
	nix run .#local

tests:
	nix run .#tests
