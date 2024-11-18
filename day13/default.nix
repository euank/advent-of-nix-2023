{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      grids = splitString "\n\n" input;
      pgrids = map (g: map stringToCharacters (splitString "\n" g)) grids;
    in pgrids;

  isReflectionVirt = g: idx:
    let
      width = arr2.width g;
      height = arr2.height g;
      toCheck = min (width - idx) idx;
      equalEls = builtins.genList (i:
        builtins.genList
        (j: (arr2.get g (idx - i - 1) j) == (arr2.get g (idx + i) j)) height)
        toCheck;
    in lists.all trivial.id (lists.flatten equalEls);

  isReflectionHoriz = g: idx:
    let
      width = arr2.width g;
      height = arr2.height g;
      toCheck = min (height - idx) idx;
      equalEls = builtins.genList (i:
        builtins.genList
        (j: (arr2.get g i (idx - j - 1)) == (arr2.get g i (idx + j))) toCheck)
        width;
    in lists.all trivial.id (lists.flatten equalEls);

  gridAnswer = g:
    let
      virt = genList (x: if isReflectionVirt g (x + 1) then (x + 1) else null)
        ((arr2.width g) - 1);
      horiz = genList (y: if isReflectionHoriz g (y + 1) then (y + 1) else null)
        ((arr2.height g) - 1);
    in findFirst (el: el != null) null
    (virt ++ (map (el: if el != null then el * 100 else null) horiz));

  part1Answer = grids: foldl' builtins.add 0 (map gridAnswer grids);

  # for part2, one smudge just means the above 'isReflected' is the same,
  # except at the end 'lists.all' becomes 'lists.allExcept1', i.e. exactly one
  # item is wrong. Just do that. Copy+paste because why not.

  isReflectionVirt2 = g: idx:
    let
      width = arr2.width g;
      height = arr2.height g;
      toCheck = min (width - idx) idx;
      equalEls = builtins.genList (i:
        builtins.genList
        (j: (arr2.get g (idx - i - 1) j) == (arr2.get g (idx + i) j)) height)
        toCheck;
    in (lists.count (el: !el) (lists.flatten equalEls)) == 1;

  isReflectionHoriz2 = g: idx:
    let
      width = arr2.width g;
      height = arr2.height g;
      toCheck = min (height - idx) idx;
      equalEls = builtins.genList (i:
        builtins.genList
        (j: (arr2.get g i (idx - j - 1)) == (arr2.get g i (idx + j))) toCheck)
        width;
    in (lists.count (el: !el) (lists.flatten equalEls)) == 1;

  gridAnswer2 = g:
    let
      virt = genList (x: if isReflectionVirt2 g (x + 1) then (x + 1) else null)
        ((arr2.width g) - 1);
      horiz =
        genList (y: if isReflectionHoriz2 g (y + 1) then (y + 1) else null)
        ((arr2.height g) - 1);
    in findFirst (el: el != null) null
    (virt ++ (map (el: if el != null then el * 100 else null) horiz));

  part2Answer = grids: foldl' builtins.add 0 (map gridAnswer2 grids);

in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer (parseInput input);
}
