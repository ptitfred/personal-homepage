{ fetchFromGitHub, lib }:

let
  gitignoreSrc = fetchFromGitHub {
    owner = "hercules-ci";
    repo = "gitignore.nix";
    rev = "a20de23b925fd8264fd7fad6454652e142fd7f73";
    sha256 = "sha256-8DFJjXG8zqoONA1vXtgeKXy68KdJL5UaXR8NtVMUbx8=";
  };
  inherit (import gitignoreSrc { inherit lib; }) gitignoreSource;
in gitignoreSource
