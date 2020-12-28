module Main (main) where

import qualified Data.Text as T
import Data.Time (fromGregorian)
import Mkv.Utils (convertEpisodeToXmlListTuples)
import Network.API.TheMovieDB
  ( Episode
      ( Episode,
        episodeAirDate,
        episodeID,
        episodeName,
        episodeNumber,
        episodeOverview,
        episodeSeasonNumber,
        episodeStillPath
      ),
  )
import Test.Tasty (TestTree, defaultMain, testGroup)
import Test.Tasty.HUnit (testCase, (@?=))

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [unitTests]

unitTests :: TestTree
unitTests =
  testGroup
    "Unit tests"
    [ testCase "Can successfully extract number, name and overview from episode" $
        let episode =
              Episode
                { episodeID = 33880,
                  episodeSeasonNumber = 1,
                  episodeStillPath = T.pack "/test",
                  episodeNumber = 1,
                  episodeName = T.pack "Welcome to Republic City",
                  episodeOverview = T.pack "In Episode 1, ...",
                  episodeAirDate = Just (fromGregorian 2012 12 12)
                }
         in convertEpisodeToXmlListTuples episode @?= [("PART_NUMBER", "1"), ("TITLE", "Welcome to Republic City"), ("SYNOPSIS", "In Episode 1, ...")]
    ]
