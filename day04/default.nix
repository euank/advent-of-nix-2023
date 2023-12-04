{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  lines = splitString "\n" (fileContents ./input);

  parseLine = line:
    let
      parts = splitString " | " line;
      winningNums = (lists.drop 2) (splitString " " (head parts));
      nums = splitStringWhitespace (last parts);
    in {
      winning = foldl' (acc: el: acc // { "${el}" = true; }) { } winningNums;
      inherit nums;
    };

  part1Answer = lines:
    let
      parsed = map parseLine lines;
      scoreLine = pline:
        let
          numWinning = foldl'
            (acc: el: acc + (if pline.winning ? "${toString el}" then 1 else 0))
            0 pline.nums;
        in if numWinning == 0 then
          0
        else if numWinning == 1 then
          1
        else
          (pow 2 (numWinning - 1));
    in foldl' builtins.add 0 (map scoreLine parsed);
in { part1 = part1Answer lines; }
