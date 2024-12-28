lint:
	nix run .#lint

dev-server:
	nix run .#dev-server -- website

tests:
	nix run .#tests

integration-tests:
	nix build --print-build-logs .#integration-tests

check-links:
	nix run .#check-links -- website

check-metas:
	nix run .#check-screenshots https://frederic.menou.me
