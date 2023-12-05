{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    # x^n
    pow = x: n: if n == 1 then x else x * (pow x (n - 1));

    splitStringWhitespace = s:
      pkgs.lib.flatten
      (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));

    trimWhitespace = s:
    let ws = [" " "\n" "\t"]; in
      if lists.any trivial.id (map (p: strings.hasPrefix p s) ws) then
        trimWhitespace (substring 1 (stringLength s) s)
      else if lists.any trivial.id (map (p: strings.hasSuffix p s) ws) then
        trimWhitespace (substring 0 ((stringLength s) - 1) s)
      else
        s;

    binarySearch = xs: cmp:
    let
      len = length xs;
    in
    if len == 0 then null
    else if len == 1 && (cmp (head xs) == 0) then (head xs)
    else if len == 1 then null
    else
    let
      lhs = sublist 0 (len / 2) xs;
      rhs = sublist (len / 2) len xs;
      p = last lhs;
      c = cmp p;
    in
    if c == 0 then p
    else if c < 0 then binarySearch lhs cmp
    else binarySearch rhs cmp;


  };
in lib
