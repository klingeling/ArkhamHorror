module Arkham.Types.Asset.Cards.JimsTrumpet
  ( JimsTrumpet(..)
  , jimsTrumpet
  ) where

import Arkham.Prelude

import qualified Arkham.Asset.Cards as Cards
import Arkham.Types.Ability
import Arkham.Types.Asset.Attrs
import Arkham.Types.Asset.Runner
import Arkham.Types.Classes
import Arkham.Types.Cost
import Arkham.Types.Id
import Arkham.Types.Message
import Arkham.Types.Query
import Arkham.Types.Target
import Arkham.Types.Token
import Arkham.Types.Window

newtype JimsTrumpet = JimsTrumpet AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, Generic, ToJSON, FromJSON, Entity)

jimsTrumpet :: AssetCard JimsTrumpet
jimsTrumpet = hand JimsTrumpet Cards.jimsTrumpet

instance HasModifiersFor env JimsTrumpet

ability :: AssetAttrs -> Ability
ability attrs =
  mkAbility (toSource attrs) 1 (LegacyReactionAbility $ ExhaustCost (toTarget attrs))

instance ActionRunner env => HasAbilities env JimsTrumpet where
  getAbilities iid (WhenRevealToken _ token) (JimsTrumpet a)
    | ownedBy a iid && tokenFace token == Skull = do
      locationId <- getId @LocationId iid
      connectedLocationIds <- map unConnectedLocationId
        <$> getSetList locationId
      investigatorIds <- for
        (locationId : connectedLocationIds)
        (getSetList @InvestigatorId)
      horrorCounts <- for
        (concat investigatorIds)
        ((unHorrorCount <$>) . getCount)
      pure [ ability a | any (> 0) horrorCounts ]
  getAbilities i window (JimsTrumpet x) = getAbilities i window x

instance AssetRunner env => RunMessage env JimsTrumpet where
  runMessage msg a@(JimsTrumpet attrs@AssetAttrs {..}) = case msg of
    UseCardAbility _ source _ 1 _ | isSource attrs source -> do
      let ownerId = fromJustNote "must be owned" assetInvestigator
      locationId <- getId ownerId
      connectedLocationIds <- map unConnectedLocationId
        <$> getSetList locationId
      investigatorIds <-
        concat <$> for (locationId : connectedLocationIds) getSetList
      pairings <- for investigatorIds
        $ \targetId -> (targetId, ) . unHorrorCount <$> getCount targetId
      let choices = map fst $ filter ((> 0) . snd) pairings
      a <$ push
        (chooseOne
          ownerId
          [ HealHorror (InvestigatorTarget iid) 1 | iid <- choices ]
        )
    _ -> JimsTrumpet <$> runMessage msg attrs
