{
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, flake-utils, haskellNix }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      supportedCompilers = [
        "ghc902"
        "ghc926"
        "ghc944"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = haskellNix.legacyPackages.${system};
        inherit (pkgs) lib;

        cremProject =
          pkgs.haskell-nix.project' {
            compiler-nix-name = "ghc902";
            src = ./.;
            evalSystem = "x86_64-linux";
          };

      in
      cremProject.flake {
        # generate project variants for each supported compiler
        variants =
          lib.attrsets.genAttrs supportedCompilers
            (compiler: { compiler-nix-name = lib.mkForce compiler; });
      });

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    allow-import-from-derivation = "true";
  };
}
