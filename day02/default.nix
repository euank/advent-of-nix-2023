{ nixpkgs, ... }:
with nixpkgs.lib;
let
  lines = splitString "\n" (fileContents ./input);

  parseGame = line:
    let
      parts = splitString ": " line;
      gameNumber = let
        h = lists.head parts;
        m = builtins.match "^Game (.*)" h;
      in toInt (elemAt m 0);
      gameSegments = splitString "; " (lists.last parts);

      parseSegment = seg:
        let
          parts = splitString ", " seg;
          parts' = map (splitString " ") parts;
        in foldl' (acc: p: acc // { "${elemAt p 1}" = toInt (head p); }) { }
        parts';
    in {
      num = gameNumber;
      segments = map parseSegment gameSegments;
    };

  part1Answer = games:
    let
      maxNums = {
        red = 12;
        green = 13;
        blue = 14;
      };
      isPossible = segment:
        let
          impossible = lists.any (trivial.id) (mapAttrsToList (key: val:
            if segment ? "${key}" then segment.${key} > val else false)
            maxNums);
        in !impossible;
      possibleGames =
        lists.filter (game: lists.all isPossible game.segments) games;
    in foldl' builtins.add 0 (map (g: g.num) possibleGames);

in { part1 = part1Answer (map parseGame lines); }
