module Solutions.Day6
  ( aoc6
  ) where

import           Common.AoCSolutions (AoCSolution (MkAoCSolution),
                                      printSolutions)
import           Text.Trifecta       (Parser)

aoc6 :: IO ()
aoc6 = do
  printSolutions 6 $ MkAoCSolution parseInput part1 part2

parseInput :: Parser String
parseInput = undefined

part1 :: String -> String
part1 = undefined

part2 :: String -> String
part2 = undefined
