{
  description = "Advent of code, 2023, solved with nix";
  outputs = { self, nixpkgs }: {
    day01 = import ./day01/default.nix { inherit nixpkgs; };
    day02 = import ./day02/default.nix { inherit nixpkgs; };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
  };
}
