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

in {
  part1 = part1Answer 0 (parseInput input) {
    instr = 0;
    node = "AAA";
  };
}
