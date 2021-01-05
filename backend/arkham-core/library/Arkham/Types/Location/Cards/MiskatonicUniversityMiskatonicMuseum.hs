module Arkham.Types.Location.Cards.MiskatonicUniversityMiskatonicMuseum
  ( MiskatonicUniversityMiskatonicMuseum(..)
  , miskatonicUniversityMiskatonicMuseum
  )
where

import Arkham.Import

import qualified Arkham.Types.EncounterSet as EncounterSet
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Helpers
import Arkham.Types.Location.Runner
import Arkham.Types.Trait

newtype MiskatonicUniversityMiskatonicMuseum = MiskatonicUniversityMiskatonicMuseum Attrs
  deriving newtype (Show, ToJSON, FromJSON)

miskatonicUniversityMiskatonicMuseum :: MiskatonicUniversityMiskatonicMuseum
miskatonicUniversityMiskatonicMuseum =
  MiskatonicUniversityMiskatonicMuseum
    $ (baseAttrs
        "50029"
        (LocationName "Miskatonic University" $ Just "Miskatonic Museum")
        EncounterSet.ReturnToTheMidnightMasks
        3
        (PerPlayer 1)
        Diamond
        [T, Plus, Circle, Square]
        [Arkham]
      )
        { locationVictory = Just 1
        }

instance HasModifiersFor env MiskatonicUniversityMiskatonicMuseum where
  getModifiersFor = noModifiersFor

ability :: Attrs -> Ability
ability attrs = base { abilityLimit = PlayerLimit PerGame 1 }
 where
  base = mkAbility (toSource attrs) 1 (ActionAbility Nothing $ ActionCost 1)

instance ActionRunner env => HasActions env MiskatonicUniversityMiskatonicMuseum where
  getActions iid NonFast (MiskatonicUniversityMiskatonicMuseum attrs@Attrs {..})
    | locationRevealed = withBaseActions iid NonFast attrs $ pure
      [ ActivateCardAbilityAction iid (ability attrs)
      | iid `member` locationInvestigators
      ]
  getActions iid window (MiskatonicUniversityMiskatonicMuseum attrs) =
    getActions iid window attrs

instance (LocationRunner env) => RunMessage env MiskatonicUniversityMiskatonicMuseum where
  runMessage msg l@(MiskatonicUniversityMiskatonicMuseum attrs@Attrs {..}) =
    case msg of
      UseCardAbility iid source _ 1 | isSource attrs source ->
        l <$ unshiftMessages
          [InvestigatorAssignDamage iid source 0 2, GainClues iid 1]
      _ -> MiskatonicUniversityMiskatonicMuseum <$> runMessage msg attrs
