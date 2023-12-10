{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      lines = splitString "\n" input;
      lines' = map (l: map toInt (splitStringWhitespace l)) lines;
    in lines';

  part1Answer = input:
    let
      diffs = line: zipListsWith (l: r: r - l) line (tail line);

      lineAnswer = line:
        if (length line) < 3 then
          throw "Too short line"
        else
          let
            l1 = last line;
            l2 = last (init line);
            l3 = last (init (init line));
          in if l1 == l2 && l2 == l3 then
            l1
          else
            l1 + (lineAnswer (diffs line));
    in foldl' builtins.add 0 (map lineAnswer input);

in { part1 = part1Answer (parseInput input); }
