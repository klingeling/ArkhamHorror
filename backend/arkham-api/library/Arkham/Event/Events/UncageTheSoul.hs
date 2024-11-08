module Arkham.Event.Events.UncageTheSoul (uncageTheSoul, uncageTheSoulEffect, UncageTheSoul (..)) where

import Arkham.Card
import Arkham.Classes
import Arkham.Cost
import Arkham.Effect.Runner
import Arkham.Event.Cards qualified as Cards
import Arkham.Event.Runner
import Arkham.Game.Helpers
import Arkham.Matcher hiding (PlayCard)
import Arkham.Prelude
import Arkham.Trait
import Arkham.Window (mkWhen)
import Arkham.Window qualified as Window

newtype UncageTheSoul = UncageTheSoul EventAttrs
  deriving anyclass (IsEvent, HasModifiersFor, HasAbilities)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

uncageTheSoul :: EventCard UncageTheSoul
uncageTheSoul = event UncageTheSoul Cards.uncageTheSoul

instance RunMessage UncageTheSoul where
  runMessage msg e@(UncageTheSoul attrs) = case msg of
    InvestigatorPlayEvent iid eid _ windows' _ | eid == toId attrs -> do
      let windows'' = nub $ windows' <> map mkWhen [Window.DuringTurn iid, Window.NonFast, Window.FastPlayerWindow]
      availableResources <- getSpendableResources iid
      results <- select $ inHandOf iid <> basic (oneOf [CardWithTrait Spell, CardWithTrait Ritual])
      cards <-
        filterM
          (getIsPlayableWithResources iid GameSource (availableResources + 3) (UnpaidCost NoAction) windows'')
          results
      player <- getPlayer iid
      choices <- for cards \c -> do
        enabled <- createCardEffect Cards.uncageTheSoul Nothing attrs (toCardId c)
        pure $ targetLabel (toCardId c) [enabled, PayCardCost iid c windows'']

      push $ chooseOne player choices
      pure e
    _ -> UncageTheSoul <$> runMessage msg attrs

newtype UncageTheSoulEffect = UncageTheSoulEffect EffectAttrs
  deriving anyclass (HasAbilities, IsEffect)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

uncageTheSoulEffect :: EffectArgs -> UncageTheSoulEffect
uncageTheSoulEffect = cardEffect UncageTheSoulEffect Cards.uncageTheSoul

instance HasModifiersFor UncageTheSoulEffect where
  getModifiersFor target@(CardIdTarget cid) (UncageTheSoulEffect attrs) | effectTarget attrs == target = do
    toModifiers attrs [ReduceCostOf (CardWithId cid) 3]
  getModifiersFor _ _ = pure []

instance RunMessage UncageTheSoulEffect where
  runMessage msg e@(UncageTheSoulEffect attrs) = case msg of
    ResolvedCard _ card | CardIdTarget (toCardId card) == effectTarget attrs -> do
      push $ disable attrs
      pure e
    _ -> UncageTheSoulEffect <$> runMessage msg attrs
