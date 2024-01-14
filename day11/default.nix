{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      lines = splitString "\n" input;
      cgrid'' = map stringToCharacters lines;
      cgrid' = genList (y:
        (genList (x: let val = arr2.get cgrid'' x y; in { inherit x y val; }))
        (length (head cgrid''))) (length cgrid'');
      cgrid = cgrid';

      emptyRows = foldl' (acc: row:
        if lists.all (el: el.val == ".") (arr2.getRow cgrid row) then
          acc ++ [ row ]
        else
          acc) [ ] (genList trivial.id (arr2.height cgrid));
      emptyCols = foldl' (acc: col:
        if lists.all (el: el.val == ".") (arr2.getCol cgrid col) then
          acc ++ [ col ]
        else
          acc) [ ] (genList trivial.id (arr2.width cgrid));

      coordinates = lists.filter (el: el != null) (lists.flatten
        ((arr2.map (e: if e.val == "#" then { inherit (e) x y; } else null)
          cgrid)));

      # Shift coordinates to expand space
      coordinates' = foldl' (coord: r:
        map (el:
          if el.y > r then {
            x = el.x;
            y = el.y + 1;
          } else
            el) coord) coordinates (lists.reverseList emptyRows);
      coordinates'' = foldl' (coord: r:
        map (el:
          if el.x > r then {
            x = el.x + 1;
            y = el.y;
          } else
            el) coord) coordinates' (lists.reverseList emptyCols);

    in coordinates'';

  part1Answer = input:
    let
      coords = parseInput input;
      pairs = cartesianProductOfSets {
        l = coords;
        r = coords;
      };
      # divide by 2 since I'm double-counting each pair of stars.
    in (foldl' builtins.add 0 (map (pair:
      let
        l = pair.l;
        r = pair.r;
      in (abs (l.x - r.x)) + (abs (l.y - r.y))) pairs)) / 2;
in { x = part1Answer input; }
