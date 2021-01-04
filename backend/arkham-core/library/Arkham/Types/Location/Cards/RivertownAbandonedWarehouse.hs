module Arkham.Types.Location.Cards.RivertownAbandonedWarehouse
  ( RivertownAbandonedWarehouse(..)
  , rivertownAbandonedWarehouse
  )
where

import Arkham.Import hiding (Cultist)

import qualified Arkham.Types.EncounterSet as EncounterSet
import Arkham.Types.Game.Helpers
import Arkham.Types.Location.Attrs
import Arkham.Types.Location.Runner
import Arkham.Types.Trait

newtype RivertownAbandonedWarehouse = RivertownAbandonedWarehouse Attrs
  deriving newtype (Show, ToJSON, FromJSON)

rivertownAbandonedWarehouse :: RivertownAbandonedWarehouse
rivertownAbandonedWarehouse = RivertownAbandonedWarehouse $ baseAttrs
  "50030"
  (Name "Rivertown" (Just "Abandoned Warehouse"))
  EncounterSet.ReturnToTheMidnightMasks
  4
  (PerPlayer 1)
  Circle
  [Moon, Diamond, Square, Squiggle, Hourglass]
  [Arkham, Central]

instance HasModifiersFor env RivertownAbandonedWarehouse where
  getModifiersFor _ _ _ = pure []

ability :: Attrs -> Ability
ability attrs =
  (mkAbility (toSource attrs) 1 (ActionAbility Nothing $ ActionCost 1))
    { abilityLimit = GroupLimit PerGame 1
    }

instance ActionRunner env => HasActions env RivertownAbandonedWarehouse where
  getActions iid NonFast (RivertownAbandonedWarehouse attrs)
    | locationRevealed attrs = withBaseActions iid NonFast attrs $ do
      hasWillpowerCards <- any (elem SkillWillpower . getSkillIcons)
        <$> getHandOf iid
      pure
        [ ActivateCardAbilityAction iid (ability attrs)
        | iid `member` locationInvestigators attrs && hasWillpowerCards
        ]
  getActions iid window (RivertownAbandonedWarehouse attrs) =
    getActions iid window attrs

instance LocationRunner env => RunMessage env RivertownAbandonedWarehouse where
  runMessage msg l@(RivertownAbandonedWarehouse attrs) = case msg of
    UseCardAbility iid source Nothing 1 | isSource attrs source -> do
      willpowerCards <- filter (elem SkillWillpower . getSkillIcons)
        <$> getHandOf iid
      let
        cardsWithCount =
          map (toFst (count (== SkillWillpower) . getSkillIcons)) willpowerCards
      l <$ unshiftMessage
        (chooseOne
          iid
          [ Run
              [ DiscardCard iid (getCardId card)
              , UseCardAbility iid source (Just $ IntMetadata n) 1
              ]
          | (n, card) <- cardsWithCount
          ]
        )
    UseCardAbility iid source (Just (IntMetadata n)) 1
      | isSource attrs source -> do
        cultists <- getSetList Cultist
        l <$ unshiftMessage
          (chooseOne iid [ RemoveDoom (EnemyTarget eid) n | eid <- cultists ])
    _ -> RivertownAbandonedWarehouse <$> runMessage msg attrs
