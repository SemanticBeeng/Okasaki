import Test.HUnit
import qualified Test.QuickCheck as QC
import Data.List (sort)
import Text.Printf (printf)
import TestHelper
import PairingHeap


main = do printTime $ runTestTT hunitTests
          printTime $ mapM_ (\(s,a) -> printf "%-25s: " s >> a) qcheckTests

hunitTests = TestList [
  "fromList" ~:
  [
    testHeap "" ~? "empty",
    testHeap ['a'..'z'] ~? "ascending",
    testHeap ['z','y'..'a'] ~? "descending",
    testHeap (['a'..'z'] ++ ['z','y'..'a']) ~? "combined asc/desc",
    testHeap (['z','y'..'a'] ++ ['a'..'z']) ~? "combined desc/asc",
    testHeap (['a'..'z'] ++ replicate 20 'm') ~? "asc/const"
  ], 
  
  "merge" ~:
  [
    testMerge ("", ['a'..'z']) ~? "empty/asc",
    testMerge (['a'..'z'], "") ~? "asc/empty",
    testMerge (['a'..'z'], ['z','y'..'a']) ~? "asc/desc",
    testMerge (['z','y'..'a'], ['a'..'z']) ~? "desc/asc"
  ] ]

qcheckTests = [ 
  ("fromList", qcheck (testHeap :: [Int] -> Bool)), 
  ("merge", qcheck (testMerge :: ([Int], [Int]) -> Bool))]

qcheck :: QC.Testable a => a -> IO ()
qcheck = --QC.quickCheck
         --QC.verboseCheck
         QC.check $ QC.defaultConfig { QC.configMaxTest = 500 }


testHeap xs = testHeap' (fromList xs) (sort xs)

testHeap' :: Ord a => PairingHeap a -> [a] -> Bool
testHeap' h xs = toSortedList h == xs


testMerge (xs, ys) = testHeap' (merge (fromList xs) (fromList ys))
                               (sort (xs ++ ys))
