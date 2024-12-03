{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    # x^n
    pow = x: n: if n == 1 then x else x * (pow x (n - 1));

    setlist = n: val: arr:
      (sublist 0 n arr) ++ [ val ] ++ (sublist (n + 1) (length arr) arr);

    removeLast = cmp: el: arr:
      if (length arr) == 0 then
        [ ]
      else if (cmp (last arr) el) == 0 then
        init arr
      else
        (removeLast cmp el (init arr)) ++ [ (last arr) ];

    splitStringWhitespace = s:
      pkgs.lib.flatten
      (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));

    trimWhitespace = s:
      let ws = [ " " "\n" "	" ];
      in if lists.any trivial.id (map (p: strings.hasPrefix p s) ws) then
        trimWhitespace (substring 1 (stringLength s) s)
      else if lists.any trivial.id (map (p: strings.hasSuffix p s) ws) then
        trimWhitespace (substring 0 ((stringLength s) - 1) s)
      else
        s;

    binarySearch = xs: cmp:
      let len = length xs;
      in if len == 0 then
        null
      else if len == 1 && (cmp (head xs) == 0) then
        (head xs)
      else if len == 1 then
        null
      else
        let
          lhs = sublist 0 (len / 2) xs;
          rhs = sublist (len / 2) len xs;
          p = last lhs;
          c = cmp p;
        in if c == 0 then
          p
        else if c < 0 then
          binarySearch lhs cmp
        else
          binarySearch rhs cmp;

    gcd = lhs: rhs: if lhs == 0 then rhs else gcd (trivial.mod rhs lhs) lhs;
    lcm = lhs: rhs: (lhs * rhs) / (gcd lhs rhs);
    abs = num: if num < 0 then (-1) * num else num;

    arr2 = rec {
      width = arr: if (length arr) == 0 then 0 else length (elemAt arr 0);
      height = length;

      get = arr: x: y: elemAt (elemAt arr y) x;
      set = arr: x: y: val:
        let
          toY = sublist 0 y arr;
          elY = elemAt arr y;
          afterY = sublist (y + 1) ((length arr) - (y + 1)) arr;
          toX = sublist 0 x elY;
          afterX = sublist (x + 1) ((length elY) - (x + 1)) elY;
        in toY ++ [ (toX ++ [ val ] ++ afterX) ] ++ afterY;

      getRow = arr: i: elemAt arr i;
      getCol = arr: i: genList (y: get arr i y) (height arr);

      map = f: arr:
        genList (y: genList (x: f (get arr x y)) (length (head arr)))
        (length arr);

      imap = f: arr:
        genList (y: genList (x: f x y (get arr x y)) (length (head arr)))
        (length arr);

      rotate = arr:
        let
          w = width arr;
          h = height arr;
        in genList (x: genList (y: get arr x (h - y - 1)) h) w;

      rotate' = arr: rotate (rotate (rotate arr));
    };
  };
in lib
