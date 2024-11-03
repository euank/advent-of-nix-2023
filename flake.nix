{
  description = "Advent of code, 2023, solved with nix";
  outputs = { self, nixpkgs }:
    let
      lib = import ./lib.nix { pkgs = nixpkgs; };
      dayDirs =
        nixpkgs.lib.filterAttrs (name: _: nixpkgs.lib.hasPrefix "day" name)
        (builtins.readDir ./.);
    in {
      inherit lib;
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      check = import ./check.nix { inherit nixpkgs lib; };
    } // (nixpkgs.lib.mapAttrs
      (name: _: import ./${name} { inherit nixpkgs lib; }) dayDirs);
}
