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

  # part2
  part2Answer = lines:
    let
      parsed = map parseLine lines;
      lineWinning = pline:
        let
          numWinning = foldl'
            (acc: el: acc + (if pline.winning ? "${toString el}" then 1 else 0))
            0 pline.nums;
        in numWinning;

      # Score is the current score
      # line is the current line
      # lines is remaining lines
      # counts is the number of cards on all future lines currently
      doIt = score: line: lines: counts:
        let
          count = head counts;
          lw = lineWinning line;
          nw = lw * count;
          incCounts = n: cs:
            if n == 0 then
              cs
            else if (length cs) == 0 then
              [ ]
            else
              [ ((head cs) + count) ] ++ (incCounts (n - 1) (tail cs));
          counts' = incCounts lw (tail counts);
        in if (length lines) == 0 then
          (score + count)
        else
          doIt (score + count) (head lines) (tail lines) counts';
    in doIt 0 (head parsed) (tail parsed) (genList (x: 1) ((length lines) + 1));
in {
  part1 = part1Answer lines;
  part2 = part2Answer lines;
}
