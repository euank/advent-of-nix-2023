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

#### day08

This day does not evaluate with Lix at the time of writing

```
$ nix --version
nix (Lix, like Nix) 2.91.1
$ nix eval --option max-call-depth 4294967295 '.#day08'
error: stack overflow (possible infinite recursion)

$ nix --version
nix (Nix) 2.18.1
$ nix eval --option max-call-depth 4294967295 '.#day08'
{ part1 = 11911; part2 = 10151663816849; }
```

### day16

You may need a larger call depth:

```
$ nix eval --option max-call-depth 4294967295 '.#day16'
```
