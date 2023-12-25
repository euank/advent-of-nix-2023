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
    in cgrid;

  trimOutsideGrid = grid: els:
    let
      height = length grid;
      width = length (head grid);
    in filter (el: el.x >= 0 && el.y >= 0 && el.x < width && el.y < height) els;

  findAdjacent = grid: el:
    let
      N = rec {
        x = el.x;
        y = el.y - 1;
        val = (arr2.get grid x y).val;
      };
      S = rec {
        x = el.x;
        y = el.y + 1;
        val = (arr2.get grid x y).val;
      };
      E = rec {
        x = el.x + 1;
        y = el.y;
        val = (arr2.get grid x y).val;
      };
      W = rec {
        x = el.x - 1;
        y = el.y;
        val = (arr2.get grid x y).val;
      };
    in if el.val == "S" then
      let
        # Find things that connect to us directly, there should be two.
        connectsToS = s: el: any (adj: adj.val == s.val) (findAdjacent grid el);
        connected = filter (connectsToS el) (trimOutsideGrid grid [ N S E W ]);
      in connected
    else
      let
        diffs = {
          "|" = [ N S ];
          "-" = [ E W ];
          "L" = [ N E ];
          "J" = [ N W ];
          "7" = [ S W ];
          "F" = [ S E ];
          "." = [ ];
        }."${el.val}";
      in trimOutsideGrid grid diffs;

  part1Answer = grid:
    let
      s = findFirst (a: a.val == "S") null (flatten grid);

      traverse = len: seen: grid: cur:
        let
          adj = findAdjacent grid cur;
          adj1 = elemAt adj 0;
          adj2 = elemAt adj 1;
          next = if !(arr2.get seen adj1.x adj1.y) then
            adj1
          else if !(arr2.get seen adj2.x adj2.y) then
            adj2
          else
            null;
        in if next == null then
          len
        else
          traverse (len + 1) (arr2.set seen cur.x cur.y true) grid next;
    in (traverse 1 (arr2.map (_: false) grid) grid s) / 2;
in { part1 = part1Answer (parseInput input); }
