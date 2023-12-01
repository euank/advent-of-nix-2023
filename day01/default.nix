{ nixpkgs, ... }:
with nixpkgs.lib;
let
  lines = splitString "\n" (fileContents ./input);

  firstDigit = line:
    let
      chars = stringToCharacters line;
      firstDigit = lists.findFirst (c: c <= "9" && c >= "0") 0 chars;
    in (strings.toInt firstDigit);

  lastDigit = line:
    (firstDigit
      (strings.concatStrings ((lists.reverseList (stringToCharacters line)))));

  part1Answer = let
    nums = builtins.map (line: (firstDigit line) * 10 + (lastDigit line)) lines;
  in foldl' (builtins.add) 0 nums;
in { part1 = part1Answer; }
