{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  part1Answer = input:
    let
      grid = map stringToCharacters (splitString "\n" input);
      virtStrings = builtins.genList (x:
        foldl' (acc: el: "${acc}${el}") ""
        (builtins.genList (y: arr2.get grid x y) (arr2.height grid)))
        (arr2.width grid);

      # And now, for each virtical line move the rocks north
      moveRocks = line:
        let
          parts = splitString "#" line;
          movePart = part:
            let
              numOs = foldl (acc: el: acc + (if el == "O" then 1 else 0)) 0
                (stringToCharacters part);
            in concatStrings ((replicate numOs "O")
              ++ (replicate ((stringLength part) - numOs) "."));
        in concatStrings (intersperse "#" (map movePart parts));

      scoreLine = line:
        foldl' builtins.add 0 (imap1 (idx: el: if el == "O" then idx else 0)
          (reverseList (stringToCharacters line)));
    in foldl' builtins.add 0 (map scoreLine (map moveRocks virtStrings));

in { part1 = part1Answer input; }
