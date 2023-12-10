{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      lines = splitString "\n" input;
      instrs = stringToCharacters (head lines);
      parseStep = line:
        let matches = builtins.match "^(...) = \\((...), (...)\\)$" line;
        in {
          "${elemAt matches 0}" = {
            L = elemAt matches 1;
            R = elemAt matches 2;
          };
        };
    in {
      inherit instrs;
      nodes =
        foldl' (acc: el: acc // el) { } (map parseStep (tail (tail lines)));
    };

  stepNode = i: input: node:
    let instr = elemAt (input.instrs) (trivial.mod i (length input.instrs));
    in input.nodes."${node}"."${instr}";

  part1Answer = numSteps: input: state:
    if state.node == "ZZZ" then
      numSteps
    else
      let
        instr =
          elemAt (input.instrs) (trivial.mod state.instr (length input.instrs));
      in part1Answer (numSteps + 1) input {
        instr = state.instr + 1;
        node = let n = input.nodes."${state.node}";
        in if instr == "L" then n.L else n.R;
      };

  # part 2

  # We need to be at least a little more clever for part2.
  # Clearly, things loop because the instruction length is small, and it takes
  # forever, so each one is on a different length loop after a certain amount
  # of time.
  # So, for each start node, find where the first loop is, find where in the
  # loop Zs are, and then put them together into a system of equations
  #
  # In practice, I ran this with debug output, and for my input got the following:
  #  { "loopLength": 11911,
  #    "loopsAt": 8,
  #    "zs": [ 11911 ] },
  #  { "loopLength": 14681,
  #    "loopsAt": 4,
  #    "zs": [ 14681 ] },
  #  { "loopLength": 19667,
  #    "loopsAt": 2,
  #    "zs": [ 19667 ] },
  #  { "loopLength": 16897,
  #    "loopsAt": 3, "zs": [ 16897 ] },
  #  { "loopLength": 13019,
  #    "loopsAt": 2, "zs": [ 13019 ] },
  #  { "loopLength": 21883,
  #    "loopsAt": 2,
  #    "zs": [ 21883 ] }
  #
  # From this, we can observe everything always loops at a Z node, after taking 2, 3, 4, or 8 steps.
  # Since we loop at a "Z" node, that means the LCM of the loop lengths will be
  # when they're all at the start, and thus all at Z nodes...
  # We don't even need to add in the "loopsAt" offset, like I originally
  # thought, because they all get into a loop within the first set of
  # instructions, and "join" the loop at the right time, so we really can just LCM.
  # Anyway, that works for my input, and I assume it will for all of em, so
  # based on reading the above debug output, LCM time.

  findZs = i: input: node: loopsAt: loopLength:
    if i == (loopsAt + loopLength) then
      [ ]
    else
      (if (hasSuffix "Z" node) then [ i ] else [ ])
      ++ findZs (i + 1) input (stepNode i input node) loopsAt loopLength;

  processNode = startNode: numSteps: node: input: hist:
    let idxMod = trivial.mod numSteps (length input.instrs);
    in if hist ? "${toString idxMod}.${node}" then
    # looping
      let
        loopsAt = hist."${toString idxMod}.${node}";
        loopLength = numSteps - loopsAt;
        zs = findZs 0 input startNode loopsAt loopLength;
      in { inherit loopsAt loopLength zs; }
    else
    # Not looping
      let hist' = hist // { "${toString idxMod}.${node}" = numSteps; };
      in processNode startNode (numSteps + 1) (stepNode numSteps input node)
      input hist';

  part2Answer = numSteps: input: state:
    let
      # I printed this to figure out what to do
      intermediateOutput =
        map (node: processNode node 0 node input ({ })) state.nodes;
      lengths = map (el: el.loopLength) intermediateOutput;
    in foldl' lcm (head lengths) (tail lengths);

  pinput = parseInput input;
in {
  part1 = part1Answer 0 pinput {
    instr = 0;
    node = "AAA";
  };
  part2 = part2Answer 0 pinput {
    instr = 0;
    nodes = filter (strings.hasSuffix "A") (attrNames pinput.nodes);
  };
}
