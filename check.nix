# Expected output for `nix run '.#check'`
{ nixpkgs, lib }:

let
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  answers = {
    "day01" = {
      part1 = 54667;
      part2 = 54203;
    };
    "day02" = {
      part1 = 2207;
      part2 = 62241;
    };
    "day03" = {
      part1 = 538046;
      part2 = 81709807;
    };
    "day04" = {
      part1 = 21138;
      part2 = 7185540;
    };
    "day05" = {
      part1 = 51580674;
      part2 = 99751240;
    };
    "day06" = {
      part1 = 1413720;
      part2 = 30565288;
    };
    "day07" = {
      part1 = 253954294;
      part2 = 254837398;
    };
    "day08" = {
      part1 = 11911;
      part2 = 10151663816849;
    };
    "day09" = {
      part1 = 1916822650;
      part2 = 966;
    };
    "day10" = {
      part1 = 6968;
      part2 = 413;
    };
    "day11" = {
      part1 = 9693756;
      part2 = 717878258016;
    };
  };

  checkDay = day:
    let
      answer = answers."${day}";
      actual = import ./${day} { inherit nixpkgs lib; };
    in if answer == actual then
      true
    else
      throw "${day} not equal; ${builtins.toJSON actual} != ${
        builtins.toJSON answer
      }";
in {
  all = pkgs.writeShellScriptBin "check.sh"
    (pkgs.lib.strings.concatStringsSep "\n" ([ "set -x" ]
      ++ (pkgs.lib.attrsets.mapAttrsToList (day: _:
        "nix eval '.#check.${day}' &>/dev/null && echo -e '\\033[0;32m${day} pass\\033[0m' || echo -e '\\033[0;31m${day} failed\\033[0m'")
        answers)));
} // (pkgs.lib.mapAttrs (day: _: checkDay day) answers)
