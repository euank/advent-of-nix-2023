{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = splitString ",";

  hashStr = str:
    foldl' (acc: c: mod ((acc + (strings.charToInt c)) * 17) 256) 0
    (stringToCharacters str);

  part1Answer = input:
    let p = parseInput input;
    in foldl' builtins.add 0 (map hashStr p);

  parseInput2 = input:
    let
      ps = parseInput input;
      parseP = p:
        let spl = builtins.split "(-|=)" p;
        in rec {
          op = head (elemAt spl 1);
          s = head spl;
          hash = hashStr s;
          arg = if (elemAt spl 2) != "" then toInt (elemAt spl 2) else null;
          inherit spl;
        };
    in map parseP ps;

  part2Answer = input:
    let
      ops = parseInput2 input;
      init = builtins.genList (_: [ ]) 256;

      cmpL = l: r: compare l.name r.name;

      processOp = hm: op:
        let
          box = elemAt hm op.hash;
          existing = findFirst (el: el.name == op.s) null
            (imap0 (idx: el: el // { inherit idx; }) box);
        in if op.op == "-" then
          setlist op.hash (removeLast cmpL ({ name = op.s; }) box) hm
        else if op.op == "=" then
          if existing != null then
            setlist op.hash (setlist existing.idx ({
              name = op.s;
              val = op.arg;
            }) box) hm
          else
            setlist op.hash (box ++ [{
              name = op.s;
              val = op.arg;
            }]) hm
        else
          throw "ahh ${op.op}";

      processed = foldl' processOp init ops;

      scoreBox = hm: idx:
        foldl' (acc: el: acc + (idx + 1) * el.el.val * el.idx) 0 (imap1 (i: a: {
          el = a;
          idx = i;
        }) (elemAt hm idx));
    in foldl' (acc: idx: acc + (scoreBox processed idx)) 0
    (builtins.genList trivial.id 256);

in {
  part1 = part1Answer input;
  part2 = part2Answer input;
}
