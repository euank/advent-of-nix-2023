{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let grid = map stringToCharacters (splitString "\n" input);
    in builtins.genList (x:
      foldl' (acc: el: acc ++ [ el ]) [ ]
      (builtins.genList (y: arr2.get grid x y) (arr2.height grid)))
    (arr2.width grid);

  grid = parseInput input;

  moveRocks = line:
    let
      parts = splitString "#" (concatStrings line);
      movePart = part:
        let
          numOs = foldl (acc: el: acc + (if el == "O" then 1 else 0)) 0
            (stringToCharacters part);
        in concatStrings ((replicate numOs "O")
          ++ (replicate ((stringLength part) - numOs) "."));
    in stringToCharacters
    (concatStrings (intersperse "#" (map movePart parts)));

  scoreLine = line:
    foldl' builtins.add 0
    (imap1 (idx: el: if el == "O" then idx else 0) (reverseList line));

  part1Answer = grid:
    foldl' builtins.add 0 (map scoreLine (map moveRocks grid));

  part2Answer = grid:
    let

      runCycle = grid:
        foldl' (grid: _: arr2.rotate' (map moveRocks grid)) grid
        (builtins.genList (_: 0) 4);

      findCycle = hist: grid:
        let
          next = runCycle grid;
          histEl = findFirst (el: el != null) null
            (lists.imap0 (i: el: if el == next then i else null) hist);
        in if histEl != null then {
          start = histEl;
          len = (length hist) - histEl;
        } else
          findCycle (hist ++ [ next ]) next;

      cycle = findCycle grid grid;
      # We found a cycle that starts at cycle.start and has a period of cycle.len
      # Run it enough times to start the cycle, then the mod
      toRun = cycle.start + (trivial.mod (1000000000 - cycle.start) cycle.len);
    in foldl' builtins.add 0 (map scoreLine
      (foldl' (grid: _: runCycle grid) grid (builtins.genList (_: 0) toRun)));

in {
  part1 = part1Answer grid;
  part2 = part2Answer grid;
}
