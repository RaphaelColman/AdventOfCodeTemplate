# Advent of Code 2021

# Table of Contents
- [Advent of Code 2021](#advent-of-code-2021)
- [Table of Contents](#table-of-contents)
    - [Overview](#overview)
    - [Getting started](#getting-started)
- [Write up](#write-up)
    - [Day 1](#day-1)
    - [Day 2](#day-2)

### Overview
This is inspired by mstksg's fantastic Haskell solutions found [here](https://github.com/mstksg/advent-of-code-2020).

This year I'll attempt to write my thoughts on each day's solution, and why this challenge is so much fun in Haskell. You can use this repo as a starter project for writing your own solutions in Haskell as it abstracts away the slightly tricky IO/reading puzzle input from file etc.

### Getting started
See [here](https://www.haskell.org/platform/) for how to install the Haskell platform.
This repo is built using [stack](https://docs.haskellstack.org/en/stable/README/) which you will also need to install. After that, run `stack build` to build the project.

This project uses a .env file for configuration. See `.env.example` to create your own. You can get your session key by logging into Advent of Code then inspecting your cookies. After that, the project will handle getting your puzzle input and caching it in the /res directory.

To solve a day, just open the corresponding DayX.hs file in the /solutions directory. Each solution must be of the form:
```
data AoCSolution a b c =
  MkAoCSolution
    { _parser :: Parser a
    , _part1  :: a -> b
    , _part2  :: a -> c
    }
```
See Day1.hs for an example, which has been implemented for day 1.

To run, you can use the GHCI repl. For example:
```
❯ stack ghci
Using main module: 1. Package `AdventOfCode2021' component AdventOfCode2021:exe:AdventOfCode2021-exe with main-is file: /Users/raphael.colman/Dev/AdventOfCode2021/app/Main.hs
AdventOfCode2021> initial-build-steps (lib + exe)
The following GHC options are incompatible with GHCi and have not been passed to it: -threaded
Configuring GHCi with the following packages: AdventOfCode2021
...

λ: aoc1
Part 1:
Success (Just 538464)
Part 2:
Success (Just 278783190)
Right ()

```

This is good for trialling solutions, because `:r` will reload your changes. You can also use the `printTestSolutions` function to use inputs from /res/test_inputs instead

Alternatively, you can build and run the application completely
```
❯ stack build
❯ stack exec AdventOfCode2021-exe
Which day of Advent do you want to solve? [1-25]
1
Part 1:
Success (Just 538464)
Part 2:
Success (Just 278783190)
Right ()
```


# Write up
### Day 1
Day 1 is always more of a warm-up puzzle. In this case, the 'puzzle bit' is figuring out how to convert a list like:
`[1,2,3,4,5,6,7,8]` into `[(1,2),(2,3),(3,4),(4,5),(5,6),(6,7),(7,8)]`.
Fortunately, the `zip` function comes to the rescue, which 'zips' through two lists at the same time and makes a tuple of the two values. So
```
zip [1,2,3] [4,5,6] --> [(1,4), (2,5), (3,6)]
```

With some smart pattern matching, we can zip a list with the same list minus the first element:
```
window2 :: [a] -> [(a, a)]
window2 l@(_:xs) = zip l xs
window2 _        = []
```
After that it's just a matter of filtering the tuples to leave only those where the second item is greater than the first:
```
sonarSweep :: [Int] -> Int
sonarSweep = length . filter id . map (\(x, y) -> y > x) . window2
```

For part 2, we do almost exactly the same thing, except this time we use `zip3` which, as the name implies, will 'zip' through three lists
```
window3 :: [a] -> [(a, a, a)]
window3 l@(_:y:xs) = zip3 l (y : xs) xs
window3 _          = []
```

Adding the items in the tuple together is pretty easy:
```
part2 :: Depths -> Int
part2 = sonarSweep . map (\(x, y, z) -> x + y + z) . window3
```

We can actually write a generic `windowN` function which creates windows of arbitrary length:
```
windowN :: Int -> [a] -> [[a]]
windowN n xs = filter ((== n) . length) $ map (take n) $ tails xs
```
but personally, I think I prefer the window2/window3 version. Those ones make tuples rather than lists, which means you have compile-time guarantees about their length.

### Day 2
I made the mistake of adding [this browser extension](https://chrome.google.com/webstore/detail/advent-of-code-charts/ipbomkmbokofodhhjpipflmdplipblbe) and looking at delta times. I guess I'm just quite slow!
Also not such a challenging day today. I chose to use the excellent [Linear V2](https://hackage.haskell.org/package/linear-1.20.7/docs/Linear-V2.html) package to keep track of position. Probably overkill, as the reason you would use V2 is in order to add positions together like vectors, and I barely ended up doing that! :man-facepalming:
```
data Direction
  = Forward
  | Up
  | Down
  deriving (Show, Eq, Enum)

data Instruction =
  MkInstruction
    { _direction :: Direction
    , _amount    :: Integer
    }
  deriving (Show, Eq)

type Position = V2 Integer
```
To implement, it's just folding over a list. You have to use `foldl` to ensure to fold from left to right. To fold, you need an aggregating function:
```
addInstruction :: Instruction -> Position -> Position
addInstruction (MkInstruction direction amount) pos =
  case direction of
    Up      -> pos - V2 0 amount
    Down    -> pos + V2 0 amount
    Forward -> pos + V2 amount 0
```
And of course to supply it with a 'starting value' (in this case `V2 0 0`)
So part 1 becomes:
```
part1 :: [Instruction] -> Integer
part1 = (\(V2 x y) -> x * y) . foldl' (flip addInstruction) (V2 0 0)
```
the 'flip' is because `addInstruction` takes an `Instruction` first, then a `Position`, whereas foldl' needs it to be the other way around (ie a -> b -> a). Flip will just reverse the order of the two parameters.

For part 2, we need more state than just position. Now it's position and aim:
```
data PositionWithAim =
  MkPositionWithAim
    { _position :: Position
    , _aim      :: Integer
    }
  deriving (Show, Eq)
```
Which makes our aggregating function look like this:
```
addInstructionWithAim :: Instruction -> PositionWithAim -> PositionWithAim
addInstructionWithAim (MkInstruction direction amount) (MkPositionWithAim position aim) =
  case direction of
    Up      -> MkPositionWithAim position $ aim - amount
    Down    -> MkPositionWithAim position $ aim + amount
    Forward -> MkPositionWithAim (position + V2 amount (aim * amount)) aim
```
Bring on day 3!
