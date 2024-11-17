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
          data = stringToCharacters (head parts);
        in { inherit nums data; };
      lines = splitString "\n" input;
    in map parseLine lines;

  arrangements = memo: springs: nums:
    let
      key = "${builtins.toJSON springs}-${builtins.toJSON nums}";
      # If we've already dealt with all springs, we're done and either found a working or broken arrangement
    in if (length nums) == 0 then {
      inherit memo;
      val = if (lists.any (s: s == "#") springs) then 0 else 1;
    } else if memo ? "${key}" then {
      inherit memo;
      val = memo."${key}";
    } else if let
      minNeededRemainingItems = (length nums) + (foldl' builtins.add 0 nums)
        - 1;
    in (length springs) < minNeededRemainingItems then {
      inherit memo;
      val = 0;
    } else if (head springs) == "." then
      arrangements memo (tail springs) nums
    else
    # Find an arrangement for the current group
      let
        num = head nums;
        els = take num springs;
        is_last = (length springs) == num;
        next = elemAt springs num;
        ret = if (all (s: s != ".") els) && (is_last || next != "#") then
          arrangements memo (drop (num + 1) springs) (tail nums)
        else {
          inherit memo;
          val = 0;
        };
        # Recurse into the 'wasn't a spring' case for ?
        ret' = if (head springs) == "?" then
          arrangements ret.memo (tail springs) nums
        else {
          memo = ret.memo;
          val = 0;
        };
      in rec {
        val = ret.val + ret'.val;
        memo = ret'.memo // { "${key}" = val; };
      };

  part1Answer = lines:
    let
      ret = foldl' (acc: line:
        let el = arrangements acc.memo line.data line.nums;
        in {
          memo = el.memo;
          val = acc.val + el.val;
        }) {
          val = 0;
          memo = { };
        } lines;
    in ret.val;

  unfoldSprings = map (l: {
    nums = flatten (replicate 5 l.nums);
    data = stringToCharacters (concatStrings
      (flatten (intersperse "?" (replicate 5 (concatStrings l.data)))));
  });

  part2Answer = lines: part1Answer (unfoldSprings lines);

in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer (parseInput input);
}
