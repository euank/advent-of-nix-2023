{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      parts = map (p: trimWhitespace (elemAt (splitString ":" p) 1))
        (splitString "\n\n" input);
      seeds = map toInt (splitString " " (elemAt parts 0));
      mappings = genList (i: elemAt parts (i + 1)) 7;

      parseMapping = mapping:
        let
          lines = map (splitString " ") (splitString "\n" mapping);
          parsedNumbers = map (l: map toInt l) lines;
          # Create a sorted list with the info so we can do efficient lookups
          parsedNumbers' = map (nums: {
            start = elemAt nums 1;
            len = elemAt nums 2;
            to = elemAt nums 0;
          }) parsedNumbers;
          sorted = lists.sort (l: r: l.start < r.start) parsedNumbers';
        in sorted;
    in {
      inherit seeds;
      mappings = map parseMapping mappings;
    };

  doMapping = num: mapping:
    # See if this is in the mapping
    let
      m = binarySearch mapping (el:
        if num < el.start then
          (-1)
        else if num > (el.start + el.len) then
          1
        else
          0);
    in if m == null then num else num - m.start + m.to;

  part1Answer = input:
    let
      parsed = parseInput input;
      doMappings = n: mappings:
        if (length mappings) == 0 then
          n
        else
          doMappings (doMapping n (head mappings)) (tail mappings);
      res = map (seed: doMappings seed parsed.mappings) parsed.seeds;
    in foldl' trivial.min (head res) (tail res);

in { part1 = part1Answer input; }
