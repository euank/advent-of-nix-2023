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

  applySingleMapping = num: m: if m == null then num else num - m.start + m.to;
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
    in applySingleMapping m;

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

  # part2
  # Map one range into possibly multiple ranges using the given mapping.
  doRangeMappings = range: mapping:
    let
      start = head range;
      end = elemAt range 1;
      range' = tail (tail range);
      # Find the mapping nearest to start
      m =
        findFirst (el: el.start >= start || ((el.start + el.len - 1) >= start))
        null mapping;
      mappingStart = trivial.max start m.start;
      mappingEnd = trivial.min end (m.start + m.len - 1);
    in if (length range) == 0 then
    # We processed all ranges for this mapping
      [ ]
    else if m == null then
    # null here means we have no mappings, numbers just go directly over
      [ start end ] ++ (doRangeMappings range' mapping)
    else if mappingStart > end || mappingEnd < start then
    # The nearest mapping doesn't actually contain us; we map over directly
      [ start end ] ++ (doRangeMappings range' mapping)
    else
    # Otherwise, we need to map the given range, and possibly carve out up to
    # two new ranges (the range before the mapping and after)
      let
        # Map what we should
        mappedRange = [
          (applySingleMapping mappingStart m)
          (applySingleMapping mappingEnd m)
        ];
        # Anything before the mapping
        preMapped =
          if start < mappingStart then [ start (mappingStart - 1) ] else [ ];
        # Anything after
        postMapped = if end > mappingEnd then [ (mappingEnd + 1) end ] else [ ];
      in mappedRange
      ++ (doRangeMappings (preMapped ++ postMapped ++ range') mapping);

  part2Answer = input:
    let
      parsed = parseInput input;
      # Ranges of (n, len) seem harder to reason about than (start, end) for me, map over to that.
      normalizedSeeds = imap0 (i: el:
        if (mod i 2) == 0 then el else (elemAt parsed.seeds (i - 1)) + el - 1)
        parsed.seeds;
      doMappings = ranges: mappings:
        if (length mappings) == 0 then
          ranges
        else
          let
            h = head mappings;
            nextRanges = doRangeMappings ranges h;
          in doMappings nextRanges (tail mappings);
      outRanges = doMappings normalizedSeeds parsed.mappings;
    in foldl' trivial.min (head outRanges) (tail outRanges);

in {
  part1 = part1Answer input;
  part2 = part2Answer input;
}
