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
          searchWin = minTime: maxTime: fst:
            if minTime == maxTime then
              if isWinning minTime race.time race.dist then minTime else null
            else
              let
                pivot = (minTime + maxTime) / 2;
                left' = searchWin minTime pivot fst;
                right' = searchWin (pivot + 1) maxTime fst;
                left = if fst then left' else right';
                right = if fst then right' else left';
              in if isWinning pivot race.time race.dist then
                if left != null then left else pivot
              else
                right;

          firstWin = searchWin 0 race.time true;
          lastWin = searchWin 0 race.time false;
        in (lastWin - firstWin + 1);
    in foldl' (acc: race: acc * (waysToWinRace race)) 1 races;

  # part2
  parseInput2 = input:
    let
      lines = splitString "\n" input;
      time = toInt (concatStrings (tail (splitStringWhitespace (head lines))));
      dist = toInt
        (concatStrings (tail (splitStringWhitespace (head (tail lines)))));
    in { inherit time dist; };
  part2Answer = input: part1Answer [ (parseInput2 input) ];

in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer input;
}
