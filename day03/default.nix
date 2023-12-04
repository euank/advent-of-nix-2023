{ nixpkgs, ... }:
with nixpkgs.lib;
let
  cells = map stringToCharacters (splitString "\n" (fileContents ./input));

  part1Answer = cells:
    let
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
                (f (x + 1)
                  (if curNum == null then nums else (nums ++ [ curNum ])) null
                  (tail rest));
        in f 0 [ ] null line;

      numbers = imap0 parseLineNumbers cells;
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
in { part1 = part1Answer cells; }
