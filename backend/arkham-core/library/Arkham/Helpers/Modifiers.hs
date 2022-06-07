module Arkham.Helpers.Modifiers where

import Arkham.Prelude

import Arkham.Source
import Arkham.Target
import Arkham.Modifier
import {-# SOURCE #-} Arkham.GameEnv
import {-# SOURCE #-} Arkham.Game ()
import Arkham.Classes.HasModifiersFor

getModifiers
  :: Source
  -> Target
  -> GameT [ModifierType]
getModifiers source target =
  map modifierType <$> getModifiersFor source target ()
