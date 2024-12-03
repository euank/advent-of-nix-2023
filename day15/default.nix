{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = splitString ",";

  hashStr = str:
    foldl' (acc: c: mod ((acc + (strings.charToInt c)) * 17) 256) 0
    (stringToCharacters str);

  part1Answer = input:
    let p = parseInput input;
    in foldl' builtins.add 0 (map hashStr p);

in {
  part1 = part1Answer input;
  #   part2 = part2Answer input;
}
