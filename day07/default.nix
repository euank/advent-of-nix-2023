{ nixpkgs, lib, ... }:
with lib;
with nixpkgs.lib;
let
  input = fileContents ./input;

  parseInput = input:
    let
      lines = splitString "\n" input;
      hands = map (line:
        let p = splitString " " line;
        in {
          cards = stringToCharacters (elemAt p 0);
          bid = toInt (elemAt p 1);
        }) lines;
    in hands;

  # map a card to a number with stronger cards being bigger
  cardNum = c:
    if c >= "2" && c <= "9" then
      toInt c
    else
      {
        T = 10;
        J = 11;
        Q = 12;
        K = 13;
        A = 14;
      }."${c}";

  compareHands = lhs: rhs:
    let
      sortMapped = lhs: rhs:
        if lhs.count != rhs.count then
          lhs.count > rhs.count
        else
          lhs.val > rhs.val;
      sortedCounts = cards:
        sort sortMapped (mapAttrsToList (k: v: {
          card = k;
          count = length v;
          val = cardNum k;
        }) (groupBy trivial.id cards));
      lhsG = sortedCounts lhs;
      rhsG = sortedCounts rhs;

      # hand type maps a parsed hand into the type, where the type is 5 -> 0, ordered by strength;
      handType = phand:
        let
          h = head phand;
          # 4 of a kind and 5 of a kind
        in if h.count > 3 then
          (h.count + 1)
          # full house
        else if h.count == 3 && (head (tail phand)).count == 2 then
          4
          # 3 of a kind
        else if h.count == 3 then
          3
          # two pair
        else if h.count == 2 && (head (tail phand)).count == 2 then
          2
        else if h.count == 2 then
          1
        else
          0;
      lhsT = handType lhsG;
      rhsT = handType rhsG;

      comparePiecewise = lhs: rhs:
        let
          lc = head lhs;
          rc = head rhs;
        in if (cardNum lc) != (cardNum rc) then
          (cardNum lc) < (cardNum rc)
        else
          comparePiecewise (tail lhs) (tail rhs);
    in if lhsT != rhsT then lhsT < rhsT else comparePiecewise lhs rhs;

  part1Answer = hands:
    foldl' builtins.add 0 (imap1 (i: el: i * el.bid)
      (sort (l: r: compareHands l.cards r.cards) hands));

  # part2
  # We could try to share code, but I'm too lazy for that right now, rename it to "pt2" and copy+paste
  cardNumPt2 = c:
    if c >= "2" && c <= "9" then
      toInt c
    else
      {
        J = 0;
        T = 10;
        Q = 12;
        K = 13;
        A = 14;
      }."${c}";

  compareHands2 = lhs: rhs:
    let
      sortMapped = lhs: rhs:
        if lhs.count != rhs.count then
          lhs.count > rhs.count
        else
          lhs.val > rhs.val;
      sortedCounts = cards:
        sort sortMapped (mapAttrsToList (k: v: {
          card = k;
          count = length v;
          val = cardNumPt2 k;
        }) (groupBy trivial.id cards));
      lhsG = sortedCounts lhs;
      rhsG = sortedCounts rhs;

      # hand type maps a parsed hand into the type, where the type is 5 -> 0, ordered by strength;
      handType = phand:
        let
          numJokers = (findFirst (a: a.card == "J") { count = 0; } phand).count;
          nonJokers = filter (a: a.card != "J") phand;
          h = head nonJokers;
          # jokers are always just added to the largest count, that's the best
          # strat for any situation I think.
          count = h.count + numJokers;
          # 4 of a kind and 5 of a kind
        in if numJokers == 5 then
          6
        else if count > 3 then
          (count + 1)
          # full house
        else if count == 3 && (head (tail nonJokers)).count == 2 then
          4
          # 3 of a kind
        else if count == 3 then
          3
          # two pair
        else if count == 2 && (head (tail nonJokers)).count == 2 then
          2
        else if count == 2 then
          1
        else
          0;
      lhsT = handType lhsG;
      rhsT = handType rhsG;

      comparePiecewise = lhs: rhs:
        let
          lc = head lhs;
          rc = head rhs;
        in if (cardNumPt2 lc) != (cardNumPt2 rc) then
          (cardNumPt2 lc) < (cardNumPt2 rc)
        else
          comparePiecewise (tail lhs) (tail rhs);
    in if lhsT != rhsT then lhsT < rhsT else comparePiecewise lhs rhs;

  part2Answer = hands:
    foldl' builtins.add 0 (imap1 (i: el: i * el.bid)
      (sort (l: r: compareHands2 l.cards r.cards) hands));
in {
  part1 = part1Answer (parseInput input);
  part2 = part2Answer (parseInput input);
}
