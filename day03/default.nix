{ nixpkgs, ... }:
with nixpkgs.lib;
let
  cells = map stringToCharacters (splitString "\n" (fileContents ./input));

  parseLineNumbers = y: line:
    let
      f = x: nums: curNum: rest:
        if (length rest) == 0 then
          if curNum == null then nums else (nums ++ [ curNum ])
        else
          let c = head rest;
          in if c >= "0" && c <= "9" then
            (f (x + 1) nums (if curNum == null then ({
              n = (toInt c);
              inherit x y;
            }) else
              (curNum // { n = 10 * curNum.n + (toInt c); })) (tail rest))
          else
            (f (x + 1) (if curNum == null then nums else (nums ++ [ curNum ]))
              null (tail rest));
    in f 0 [ ] null line;
  numbers = imap0 parseLineNumbers cells;

  part1Answer = cells:
    let
      shouldIncludeNumber = num:
        lists.any trivial.id (flatten (genList (y:
          genList (x:
            let
              x' = num.x - 1 + x;
              y' = num.y - 1 + y;
            in if x' < 0 || y' < 0 || x' >= (length (head cells)) || y'
            >= (length cells) then
              false
            else
              let c = elemAt (elemAt cells y') x';
              in if c == "." || (c >= "0" && c <= "9") then false else true)
          ((stringLength (toString num.n)) + 2)) 3));
      included = builtins.filter shouldIncludeNumber (flatten numbers);
    in foldl' builtins.add 0 (map (n: n.n) included);

  part2Answer = cells:
    let
      parseGears = y: line:
        let
          f = x: gears: rest:
            if (length rest) == 0 then
              gears
            else
              let c = head rest;
              in f (x + 1)
              (gears ++ (if c == "*" then [{ inherit x y; }] else [ ]))
              (tail rest);
        in f 0 [ ] line;

      gears = imap0 parseGears cells;

      numbersByCoords = numbers:
        let
          numCoords = num:
            foldl' (acc: el: acc // el) ({ })
            (genList (n: { "${toString (num.x + n)}.${toString num.y}" = num; })
              (stringLength (toString num.n)));
        in foldl' (acc: num: acc // (numCoords num)) ({ }) (flatten numbers);

      numCoords = numbersByCoords numbers;

      gearAdjacentNumbers = gear:
        let
          adjacentCoords = flatten (genList (y:
            genList (x: {
              x = gear.x - 1 + x;
              y = gear.y - 1 + y;
            }) 3) 3);
          adjacentNumbers' = filter (el: el != null) (map (xy:
            if numCoords ? "${toString xy.x}.${toString xy.y}" then
              numCoords."${toString xy.x}.${toString xy.y}"
            else
              null) adjacentCoords);
          # dedupe
          adjacentNumbers = if (length adjacentNumbers' == 0) then
            [ ]
          else
            let
              sorted =
                lists.sort (l: r: if l.x == r.x then l.y < r.y else l.x < r.x)
                adjacentNumbers';
            in foldl' (acc: el:
              let l = lists.last acc;
              in if l.x == el.x && l.y == el.y then acc else acc ++ [ el ])
            [ (head sorted) ] (tail sorted);
        in adjacentNumbers;
    in foldl' (acc: g:
      let ad = gearAdjacentNumbers g;
      in acc
      + (if (length ad) == 2 then (foldl' (acc: a: acc * a.n) 1 ad) else 0)) 0
    (flatten gears);
in {
  part1 = part1Answer cells;
  part2 = part2Answer cells;
}
