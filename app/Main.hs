module Main where

import Control.Monad.IO.Class ()
import Control.Monad.Trans.Except (ExceptT (ExceptT), runExceptT)
import qualified Data.Text as T
import Mkv.Utils (convertEpisodeToXmlListTuples)
import Network.API.TheMovieDB
  ( Episode (episodeName, episodeNumber, episodeOverview),
    Error (..),
    ItemID,
    TV,
    TheMovieDB,
    defaultSettings,
    fetchFullTVSeries,
    fetchTVSeason,
    runTheMovieDB,
    seasonEpisodeCount,
    seasonEpisodes,
  )
import Network.API.TheMovieDB.Types.Season
  ( Season (seasonEpisodes),
  )
import Text.XML.HXT.Arrow.DocumentOutput (putXmlTree)
import Text.XML.HXT.Arrow.Pickle (XmlPickler, thePicklerDTD, xpickle, xpickleDocument)
import Text.XML.HXT.Arrow.Pickle.Xml
  ( PU,
    xpElem,
    xpList,
    xpPair,
    xpPrim,
    xpText,
  )
import Text.XML.HXT.Arrow.WriteDocument ()
import Text.XML.HXT.Arrow.XmlArrow (ArrowXml (mkelem, txt))
import Text.XML.HXT.Arrow.XmlState (runX, withIndent, yes)
import Text.XML.HXT.Core (ArrowList (constA), uncurry3, uncurry4, (>>>))

xpSimple :: PU (String, String)
xpSimple = xpElem "Simple" $ xpPair (xpElem "Name" xpText) (xpElem "String" xpText)

xpSimpleList :: PU [(String, String)]
xpSimpleList = xpList xpSimple

xpEpisodeTarget :: PU Int
xpEpisodeTarget = xpElem "Targets" $ xpElem "TargetTypeValue" xpPrim

xpEpisode :: PU (Int, [(String, String)])
xpEpisode = xpElem "Tag" $ xpPair xpEpisodeTarget xpSimpleList

fetchSeasonFromTVId :: ItemID -> Int -> IO (Either Error [Episode])
fetchSeasonFromTVId itemId seasonNr = runExceptT $ do
  let key = T.pack "apikey"
  season <- ExceptT $ runTheMovieDB (defaultSettings key) (fetchTVSeason itemId seasonNr)
  return $ seasonEpisodes season

fetchEpisodeFromTVId :: ItemID -> Int -> Int -> IO (Either Error Episode)
fetchEpisodeFromTVId itemId seasonNr episodeNr = runExceptT $ do
  episodes <- ExceptT $ fetchSeasonFromTVId itemId seasonNr
  return $ episodes !! episodeNr

main :: IO ()
main = do
  episode <- fetchEpisodeFromTVId 33880 1 0
  case episode of
    (Left err) -> print "Error"
    (Right e) -> do
      runX $ constA (50, convertEpisodeToXmlListTuples e) >>> xpickleDocument xpEpisode [withIndent yes] "test.xml"
      print "Success"
