module Arkham.Types.Treachery.Cards.WhispersInYourHeadDismay
  ( whispersInYourHeadDismay
  , WhispersInYourHeadDismay(..)
  ) where

import Arkham.Prelude

import qualified Arkham.Treachery.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Card.CardType
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Matcher
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Target
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Helpers
import Arkham.Types.Treachery.Runner

newtype WhispersInYourHeadDismay = WhispersInYourHeadDismay TreacheryAttrs
  deriving anyclass IsTreachery
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

whispersInYourHeadDismay :: TreacheryCard WhispersInYourHeadDismay
whispersInYourHeadDismay =
  treachery WhispersInYourHeadDismay Cards.whispersInYourHeadDismay

instance HasModifiersFor env WhispersInYourHeadDismay where
  getModifiersFor _ (InvestigatorTarget iid) (WhispersInYourHeadDismay a)
    | Just iid == treacheryInHandOf a = pure
    $ toModifiers a [CannotCommitCards $ CardWithType SkillType]
  getModifiersFor _ _ _ = pure []

instance HasAbilities WhispersInYourHeadDismay where
  getAbilities (WhispersInYourHeadDismay a) =
    [restrictedAbility a 1 InYourHand $ ActionAbility Nothing $ ActionCost 2]

instance TreacheryRunner env => RunMessage env WhispersInYourHeadDismay where
  runMessage msg t@(WhispersInYourHeadDismay attrs) = case msg of
    Revelation iid source | isSource attrs source ->
      t <$ push (AddTreacheryToHand iid $ toId attrs)
    UseCardAbility _ source _ 1 _ | isSource attrs source ->
      t <$ push (Discard $ toTarget attrs)
    _ -> WhispersInYourHeadDismay <$> runMessage msg attrs
