module Arkham.Types.Asset.Cards.InTheKnow1
  ( inTheKnow1
  , InTheKnow1(..)
  ) where

import Arkham.Prelude

import Arkham.Asset.Cards qualified as Cards
import Arkham.Types.Ability
import Arkham.Types.Action qualified as Action
import Arkham.Types.Asset.Attrs
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Id
import Arkham.Types.Matcher
import Arkham.Types.Target

newtype InTheKnow1 = InTheKnow1 AssetAttrs
  deriving anyclass (IsAsset, HasModifiersFor env)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

inTheKnow1 :: AssetCard InTheKnow1
inTheKnow1 = asset InTheKnow1 Cards.inTheKnow1

instance HasAbilities InTheKnow1 where
  getAbilities (InTheKnow1 attrs) =
    [ restrictedAbility attrs 1 OwnsThis
        $ ActionAbility (Just Action.Investigate)
        $ ActionCost 1
        <> UseCost (toId attrs) Secret 1
    ]

instance AssetRunner env => RunMessage env InTheKnow1 where
  runMessage msg a@(InTheKnow1 attrs) = case msg of
    UseCardAbility iid source windows' 1 _ | isSource attrs source -> do
      investigatorLocation <- getId @LocationId iid
      locations <- selectList $ RevealedLocation <> InvestigatableLocation
      locationsWithInvestigate <- concat <$> for
        locations
        \lid -> do
          investigateActions <-
            selectList
            $ AbilityOnLocation (LocationWithId lid)
            <> AbilityIsAction Action.Investigate
          pure $ map (lid, ) investigateActions
      a <$ push
        (chooseOne
          iid
          [ TargetLabel
              (LocationTarget location)
              [ SetLocationAsIf iid location
              , UseAbility iid investigate windows'
              , SetLocationAsIf iid investigatorLocation
              ]
          | (location, investigate) <- locationsWithInvestigate
          ]
        )
    _ -> InTheKnow1 <$> runMessage msg attrs
