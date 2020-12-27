module Main where

import Network.API.TheMovieDB
    ( fetchFullTVSeries,
      defaultSettings,
      runTheMovieDB,
      TheMovieDB,
      ItemID,
      Episode,
      TV )
import Text.XML.HXT.Arrow.Pickle (thePicklerDTD, xpickleDocument, XmlPickler, xpickle)
import Text.XML.HXT.Arrow.Pickle.Xml
    ( xpElem, xpList, xpPair, xpPrim, xpText, PU )
import Text.XML.HXT.Arrow.WriteDocument ()
import Text.XML.HXT.Arrow.XmlState ( runX, withIndent, yes )
import Text.XML.HXT.Arrow.DocumentOutput ( putXmlTree )
import System.Environment (getArgs)
import Text.XML.HXT.Core (uncurry4, ArrowList(constA), uncurry3, (>>>))
import Text.XML.HXT.Arrow.XmlArrow (ArrowXml(txt, mkelem))
import Data.List.NonEmpty ()

xpSimple :: PU (String, String)
xpSimple = xpElem "Simple" $ xpPair (xpElem "Name" xpText) (xpElem "String" xpText)

xpSimpleList :: PU [(String, String)]
xpSimpleList = xpList xpSimple

xpEpisodeTarget:: PU Int
xpEpisodeTarget = xpElem "Targets" $ xpElem "TargetTypeValue" xpPrim

xpEpisode :: PU (Int, [(String, String)])
xpEpisode = xpElem "Tag" $ xpPair xpEpisodeTarget xpSimpleList

main :: IO ()
main = do
   runX $ constA (50, [("PART_NUMBER", "1"), ("TITLE", "Welcome to Republic City")]) >>> xpickleDocument xpEpisode [withIndent yes] "test.xml"
   return ()
