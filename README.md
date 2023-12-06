## Advent of Nix 2023

The much-awaited sequal to [Advent of Nix 2021](https://github.com/euank/advent-of-nix-2021).

This is my go at Advent of Code (2023) in pure nix. Hiding bash or other languages in the nix isn't allowed.

### Running solutions

In general, `nix eval '.#dayX'` (where 'X' is the number of the day, padded to
length 2, such as `nix eval '.#day03'`) will display the answer to a given day.

For some days, you may have to run `nix eval '.#dayX.part1'` and `.part2` separately for them to complete.

### Performance

nix has awful computational performance. Really bad. Expect solutions to generally take a large amount of memory and time to complete.

I will note any days below which take over 8GiB of memory and/or over 5 minutes on my machine.

### Specific day's notes

#### Day 06

This one takes 15GiB of memory on my machine, but completes pretty quickly (15s or so).
