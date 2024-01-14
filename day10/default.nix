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

  # part2
  # I googled around for calculating polygon area given that we know each
  # vertex, and eventually found
  # https://en.wikipedia.org/wiki/Shoelace_formula

  vertsAndPathLen = grid:
    let
      s = findFirst (a: a.val == "S") null (flatten grid);
      traverse = vxes: seen: grid: cur:
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
          (vxes ++ [ cur ])
        else
          traverse (vxes ++ [ cur ]) (arr2.set seen cur.x cur.y true) grid next;
    in rec {
      verts = (traverse [ ] (arr2.map (_: false) grid) grid s);
      len = length verts;
    };

  part2Answer = grid:
    let
      # all points on loop
      vertsAndPath = vertsAndPathLen grid;
      pathLen = vertsAndPath.len;
      verts = vertsAndPath.verts;
      # And now shoelace it
      det = i:
        let
          cur = elemAt verts i;
          next = elemAt verts (trivial.mod (i + 1) (length verts));
        in cur.x * next.y - next.x * cur.y;
      fullArea = (abs (foldl' (acc: el: acc + (det el)) 0
        (genList trivial.id (length verts)))) / 2;
      # Knock off part of the path, see https://en.wikipedia.org/wiki/Pick%27s_theorem
      # Had to google a lot for that too, the +1 wasn't obvious to me.
    in abs ((fullArea) - (pathLen / 2) + 1);

in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer (parseInput input);
}
