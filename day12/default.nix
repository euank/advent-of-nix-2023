{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      parseLine = line:
        let
          parts = splitString " " line;
          nums = map toInt (splitString "," (elemAt parts 1));
        in {
          inherit nums;
          data = stringToCharacters (head parts);
        };
      lines = splitString "\n" input;
    in map parseLine lines;

  rowArrangements = rem: nums: lastWasSpring:
    let
      num = head nums;
      el = head rem;
      # if we have nothing left, there's no additional arrangements
    in if (length rem) == 0 then
      0
      # If there's one item left, we can check if we're in a possible configuration, i.e. the number list should be length 1 and have either 0 or 1 spring, and the el should match
    else if (length rem) == 1 then
      if (length nums) == 1 then
      # no broken springs left
        if num == 0 && (el == "?" || el == ".") then
          1
          # 1 broken spring left
        else if num == 1 && (el == "?" || el == "#") then
          1
          # impossible configuration
        else
          0
      else
        0
        # otherwise we have more than 1 item left, so search all branches
        # First case: we are on an unbroken spring, in that case, we need to check if
        # we're in a possible configuration and maybe recurse
    else if el == "." then
    # impossible arrangement
      if lastWasSpring && num > 0 then
        0
      else if lastWasSpring && num == 0 && (length nums) > 1 then
        rowArrangements (tail rem) (tail nums) false
      else
        rowArrangements (tail rem) nums false
    else if el == "#" then
    # We have a broken spring but needed none
      if num == 0 then
        0
      else
        rowArrangements (tail rem) ([ (num - 1) ] ++ (tail nums)) true
        # el is '?', we need to branch both paths
    else
      (rowArrangements ([ "." ] ++ (tail rem)) nums lastWasSpring)
      + (rowArrangements ([ "#" ] ++ (tail rem)) nums lastWasSpring);

  part1Answer = lines:
    let vals = map (line: rowArrangements line.data line.nums false) lines;
    in foldl' builtins.add 0 vals;

in { part1 = part1Answer (parseInput input); }
