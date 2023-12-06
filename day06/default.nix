{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      lines = splitString "\n" input;
      times = map toInt (tail (splitStringWhitespace (head lines)));
      dists = map toInt (tail (splitStringWhitespace (head (tail lines))));
      pairs = map (z: {
        time = z.fst;
        dist = z.snd;
      }) (zipLists times dists);
    in pairs;

  part1Answer = races:
    let
      isWinning = time: maxTime: target: (maxTime - time) * time > target;
      waysToWinRace = race:
        let
          # We could binary search, but these numbers are small, we're fnie
          firstWin = findFirst (el: isWinning el race.time race.dist) null
            (genList trivial.id race.time);
          lastWin = foldr (el: lst:
            if lst == null && isWinning el race.time race.dist then el else lst)
            null (genList trivial.id race.time);
        in (lastWin - firstWin + 1);
    in foldl' (acc: race: acc * (waysToWinRace race)) 1 races;

in { part1 = part1Answer (parseInput input); }
