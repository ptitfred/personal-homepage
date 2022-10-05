module Main where

import Effect (Effect)
import Prelude
import Web.HTML (window)
import Web.HTML.Location (hash, hostname, pathname, replace, search)
import Web.HTML.Window (location)

foreign import setupMatomo :: String -> String -> Effect Unit

main :: Effect Unit
main = redirectToSubdomain <> setupMatomo "menou" "1"

redirectToSubdomain :: Effect Unit
redirectToSubdomain = do
  loc <- location =<< window
  h <- hostname loc
  when (h == "menou.me") $ do
    partial <- (pathname <> search <> hash) loc
    let target = "https://frederic.menou.me" <> partial
    replace target loc
