module Arkham.Types.Investigator.Cards.WinifredHabbamock where

import Arkham.Import

import Arkham.Types.Investigator.Attrs
import Arkham.Types.Investigator.Runner
import Arkham.Types.Stats
import Arkham.Types.Trait

newtype WinifredHabbamock = WinifredHabbamock Attrs
  deriving newtype (Show, ToJSON, FromJSON)

instance HasModifiersFor env WinifredHabbamock where
  getModifiersFor source target (WinifredHabbamock attrs) =
    getModifiersFor source target attrs

winifredHabbamock :: WinifredHabbamock
winifredHabbamock = WinifredHabbamock $ baseAttrs
  "60301"
  "Winifred Habbamock"
  Rogue
  Stats
    { health = 8
    , sanity = 7
    , willpower = 1
    , intellect = 3
    , combat = 3
    , agility = 5
    }
  [Criminal]

instance ActionRunner env => HasActions env WinifredHabbamock where
  getActions i window (WinifredHabbamock attrs) = getActions i window attrs

instance (InvestigatorRunner env) => RunMessage env WinifredHabbamock where
  runMessage msg (WinifredHabbamock attrs) =
    WinifredHabbamock <$> runMessage msg attrs
