{ pkgs }:
with pkgs.lib;
let
  lib = rec {
    # x^n
    pow = x: n: if n == 1 then x else x * (pow x (n - 1));

    splitStringWhitespace = s: pkgs.lib.flatten (builtins.filter builtins.isList (builtins.split "([^ ]+)" s));
  };
in lib
