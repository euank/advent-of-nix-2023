{ nixpkgs, ... }:
with nixpkgs.lib;
let
  lines = splitString "\n" (fileContents ./input);

  firstDigit = line:
    let
      chars = stringToCharacters line;
      firstDigit = lists.findFirst (c: c <= "9" && c >= "0") 0 chars;
    in (strings.toInt firstDigit);

  lastDigit = line:
    (firstDigit
      (strings.concatStrings ((lists.reverseList (stringToCharacters line)))));

  part1Answer = let
    nums = builtins.map (line: (firstDigit line) * 10 + (lastDigit line)) lines;
  in foldl' (builtins.add) 0 nums;

  # part2
  digits = {
    "zero" = 0;
    "one" = 1;
    "two" = 2;
    "three" = 3;
    "four" = 4;
    "five" = 5;
    "six" = 6;
    "seven" = 7;
    "eight" = 8;
    "nine" = 9;
  };

  stringTail = string:
    let len = stringLength string;
    in builtins.substring 1 (len - 1) string;
  stringReverse = string:
    strings.concatStrings (lists.reverseList (stringToCharacters string));

  firstInstanceOfAny = string: needles:
    let
      headMatch =
        lists.findFirst (needle: strings.hasPrefix needle string) null needles;
    in if headMatch == null then
      firstInstanceOfAny (stringTail string) needles
    else
      headMatch;

  firstLastDigits = line:
    let
      needles =
        lists.flatten (mapAttrsToList (s: v: [ s (toString v) ]) digits);
      reverseNeedles = builtins.map stringReverse needles;
      firstMatch = firstInstanceOfAny line needles;
      lastMatch =
        stringReverse (firstInstanceOfAny (stringReverse line) reverseNeedles);
      toDigit = digit:
        if digits ? "${digit}" then digits."${digit}" else strings.toInt digit;
    in (10 * (toDigit firstMatch)) + (toDigit lastMatch);
  part2Answer = foldl' (builtins.add) 0 (builtins.map firstLastDigits lines);
in {
  part1 = part1Answer;
  part2 = part2Answer;
}
