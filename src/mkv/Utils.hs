module Mkv.Utils where

import qualified Data.Text as T
import Network.API.TheMovieDB
  ( Episode (episodeName, episodeNumber, episodeOverview),
  )

createEpisodeNumberTuple :: Episode -> (String, String)
createEpisodeNumberTuple = (,) "PART_NUMBER" . show . episodeNumber

createEpisodeTitleTuple :: Episode -> (String, String)
createEpisodeTitleTuple = (,) "TITLE" . T.unpack . episodeName

createEpisodeSynopsisTuple :: Episode -> (String, String)
createEpisodeSynopsisTuple = (,) "SYNOPSIS" . T.unpack . episodeOverview

convertEpisodeToXmlListTuples :: Episode -> [(String, String)]
convertEpisodeToXmlListTuples e = [createEpisodeNumberTuple e, createEpisodeTitleTuple e, createEpisodeSynopsisTuple e]