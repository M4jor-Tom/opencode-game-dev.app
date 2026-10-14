{
  description = "OpenCode, pre-loaded with the opencode-game-dev profile";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    { self
    , nixpkgs
    , systems
    }:
    let
      inherit (nixpkgs) lib;
      eachSystem = f: lib.foldl' lib.recursiveUpdate { } (map f (import systems));

      overlay = final: prev: {
        opencode-game-dev = final.callPackage ./package.nix {
          profileName = "opencode-game-dev";
          configRepo = "https://github.com/M4jor-Tom/opencode-game-dev.git";
          dirEnvVar = "OPENCODE_GAME_DEV_DIR";
        };
      };
    in
    eachSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages.${system} = {
          default = pkgs.opencode-game-dev;
          opencode-game-dev = pkgs.opencode-game-dev;
        };

        apps.${system} = {
          default = {
            type = "app";
            program = "${pkgs.opencode-game-dev}/bin/opencode-game-dev";
            meta.description = "OpenCode running the opencode-game-dev profile";
          };
          opencode-game-dev = {
            type = "app";
            program = "${pkgs.opencode-game-dev}/bin/opencode-game-dev";
            meta.description = "OpenCode running the opencode-game-dev profile";
          };
        };

        devShells.${system}.default = pkgs.mkShell {
          buildInputs = with pkgs; [ nixpkgs-fmt ];
        };
      }) // {
      overlays.default = overlay;
    };
}
