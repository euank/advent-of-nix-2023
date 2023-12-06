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
          searchWin = times:
            if length times == 0 then
              null
            else
              let
                pivot = elemAt times ((length times) / 2);
                left = searchWin (sublist 0 ((length times) / 2) times);
                right = searchWin
                  (sublist (((length times) / 2) + 1) (length times) times);
              in if isWinning pivot race.time race.dist then
                if left != null then left else pivot
              else
                right;

          firstWin = searchWin (genList trivial.id race.time);
          lastWin = searchWin (reverseList (genList trivial.id race.time));
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
