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
        if length (unique line) == 1 then
          last line
        else
          (last line) + (lineAnswer (diffs line));
    in foldl' builtins.add 0 (map lineAnswer input);

  # part2
  part2Answer = input: part1Answer (map reverseList input);

in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer (parseInput input);
}
