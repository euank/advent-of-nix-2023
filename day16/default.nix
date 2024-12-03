{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input: map stringToCharacters (splitString "\n" input);

  # grid is both memoization and state
  # it is a 2d arr of objects:
  # {
  #   val = "."; # tile value, per input
  #   up = true; # a beam has passed here going up before
  #   down = true; # a beam has passed here going down before
  #   ....
  # }
  # at the end we can see if something is energized by up || down || left || right
  # if we've seen a beam going that dir before, we can stop working, that beam
  # already passed and lit stuff up etc.
  step = grid: x: y: dir:
    let
      el = arr2.get grid x y;
      grid' = arr2.set grid x y (el // { "${dir}" = true; });
      # memo, we can stop
    in if x < 0 || y < 0 then
      grid
    else if x >= (arr2.width grid) || y >= (arr2.height grid) then
      grid
    else if el."${dir}" then
      grid
      # new
    else
      let
        nextSquares =
          if el.val == "|" && (dir == "right" || dir == "left") then [
            # splits up and down
            {
              inherit x;
              y = y + 1;
              dir = "down";
            }
            {
              inherit x;
              y = y - 1;
              dir = "up";
            }
          ] else if el.val == "-" && (dir == "down" || dir == "up") then [
            # splits left/right
            {
              inherit y;
              x = x + 1;
              dir = "right";
            }
            {
              inherit y;
              x = x - 1;
              dir = "left";
            }
          ] else if el.val == "." || el.val == "-" || el.val == "|" then
            let
              dirMap = {
                up = {
                  x = 0;
                  y = -1;
                };
                down = {
                  x = 0;
                  y = 1;
                };
                left = {
                  x = -1;
                  y = 0;
                };
                right = {
                  x = 1;
                  y = 0;
                };
              };
            in [{
              inherit dir;
              x = x + dirMap.${dir}.x;
              y = y + dirMap.${dir}.y;
            }]
          else if el.val == "/" then [{
            dir = {
              "right" = "up";
              "left" = "down";
              "up" = "right";
              "down" = "left";
            }.${dir};
            x =
              if dir == "down" then x - 1 else if dir == "up" then x + 1 else x;
            y = if dir == "right" then
              y - 1
            else if dir == "left" then
              y + 1
            else
              y;
          }] else if el.val == "\\" then [{
            dir = {
              "right" = "down";
              "left" = "up";
              "up" = "left";
              "down" = "right";
            }.${dir};
            x =
              if dir == "down" then x + 1 else if dir == "up" then x - 1 else x;
            y = if dir == "right" then
              y + 1
            else if dir == "left" then
              y - 1
            else
              y;
          }] else
            throw "yaba ${el.val}";
      in foldl' (acc: next: step acc next.x next.y next.dir) grid' nextSquares;

  part1Answer = input:
    let
      p = parseInput input;
      init = arr2.map (el: {
        val = el;
        up = false;
        down = false;
        left = false;
        right = false;
      }) p;
      finalGrid = step init 0 0 "right";
    in foldl'
    (acc: el: acc + (if el.left || el.right || el.up || el.down then 1 else 0))
    0 (flatten finalGrid);

  # brute forceable? Probably, let's find out
  part2Answer = input:
    let
      p = parseInput input;
      init = arr2.map (el: {
        val = el;
        up = false;
        down = false;
        left = false;
        right = false;
      }) p;

      scoreGrid = grid:
        foldl' (acc: el:
          acc + (if el.left || el.right || el.up || el.down then 1 else 0)) 0
        (flatten grid);

      grids = (concatMap
        (x: [ (step init x 0 "down") (step init x ((arr2.height p) - 1) "up") ])
        (builtins.genList trivial.id (arr2.width p))) ++ ((concatMap (y: [
          (step init 0 y "right")
          (step init ((arr2.width p) - 1) y "left")
        ]) (builtins.genList trivial.id (arr2.height p))));
    in foldl' trivial.max 0 (map scoreGrid grids);

in {
  part1 = part1Answer input;
  part2 = part2Answer input;
}
