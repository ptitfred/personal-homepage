module Container
  ( toggleButtonContainer
  ) where

import React.Basic (JSX)
import React.Basic.DOM as DOM

toggleButtonContainer :: JSX
toggleButtonContainer = DOM.span_ [ DOM.text "button" ]
