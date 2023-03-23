module Main where

import Effect (Effect)
import Prelude

foreign import setupMatomo :: String -> String -> Effect Unit

main :: Effect Unit
main = setupMatomo "kiwi.menou.me" "1"
