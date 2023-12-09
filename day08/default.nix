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



  # We need to be at least a little more clever for part2.
  # if we find where each node "loops" and then look for all the 'Z's there, we
  # can probably do this mathematically (the first number that all the z
  # indexes are factors of, right?)...
  # First, find each node that loops
  # Do it just for idx 0, effectively we're memoizing one idx, but that should be enough I hope
  nodeInfo = input: startNode: otherLoops:
  let
    # go this many steps, if we haven't gotten back to the start, we got stuck
    # in a loop elsewhere.
    maxSteps = (length input.instrs) * (length (attrNames input.nodes));
    step = idx: curNode: goals':
      let
        idxMod = trivial.mod idx (length input.instrs);
        instr = elemAt (input.instrs) idxMod;
        nextNode = input.nodes."${curNode}"."${if instr == "L" then "L" else "R"}";
        goals = goals' ++ (if (hasSuffix "Z" curNode) then [ idx ] else []);
      in
      if otherLoops ? "${nextNode}" && idxMod == 0 then { idx = idx + (otherLoops.${nextNode}.idx); goals = goals ++ (map (o: o + idx) otherLoops.${nextNode}.goals); }
      else if nextNode == startNode && idxMod == 0 then { inherit idx goals; }
      else if idx > maxSteps then null
      else step (idx + 1) nextNode goals;
in
  step 0 startNode [];

  part2Answer = numSteps: input: state:
  let
    loopNodes = foldl' (acc: node: let inf = nodeInfo input node acc; in if inf == null then acc else acc // { "${node}" = inf; }) {} (attrNames input.nodes);
    # Now we know when any node that does loop loops, and how far to a 'Z' node from the loop
    # Now run the sim, and be ready for loops
    idxMod = trivial.mod idx (length input.instrs);
  in
  if modIdx == 0 then
    # Use memo
    throw "TODO"
  else
  throw "TODO";

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
