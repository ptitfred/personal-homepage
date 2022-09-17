module Main where

import Prelude
import Container (toggleButtonContainer)
import Data.Maybe (maybe)
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM (render)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main :: Effect Unit
main = do
  container <- getElementById "container" =<< (map toNonElementParentNode $ document =<< window)
  let notFound = throw "Container element not found."
      found = render toggleButtonContainer
  maybe notFound found container
