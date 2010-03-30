module Web.Routes.Site where

import Data.Maybe (isJust, fromJust)
import Data.Monoid (Monoid(mappend))
import Web.Routes.Base (decodePathInfo, encodePathInfo)

data Site url a
    = Site { handleSite         :: (url -> String) -> url -> a
           , defaultPage        :: Maybe url
           , formatPathSegments :: url -> [String]
           , parsePathSegments  :: [String] -> Either String url
           }

instance Functor (Site url) where
  fmap f site = site { handleSite = \showFn u -> f (handleSite site showFn u) }

withDefault :: Site url a -> String -> Either String url
withDefault site pathInfo
  | null pathInfo && isJust (defaultPage site) = Right (fromJust (defaultPage site))
  | otherwise     = (parsePathSegments site) (decodePathInfo pathInfo)
                         
runSite :: String -> Site url a -> String -> (Either String a)
runSite approot site pathInfo =
  case (withDefault site) pathInfo of
    (Left errs) -> (Left errs)
    (Right url)  -> Right $ (handleSite site) (\url -> approot ++ (encodePathInfo $ formatPathSegments site url)) url