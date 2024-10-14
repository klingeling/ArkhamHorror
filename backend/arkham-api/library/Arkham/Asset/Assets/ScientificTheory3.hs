module Arkham.Asset.Assets.ScientificTheory3 (scientificTheory3, ScientificTheory3 (..)) where

import Arkham.Ability
import Arkham.Asset.Cards qualified as Cards
import Arkham.Asset.Import.Lifted
import Arkham.Helpers.SkillTest (withSkillTest)
import Arkham.Matcher
import Arkham.Message.Lifted.Choose
import Arkham.Modifier

newtype ScientificTheory3 = ScientificTheory3 AssetAttrs
  deriving anyclass IsAsset
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

scientificTheory3 :: AssetCard ScientificTheory3
scientificTheory3 = assetWith ScientificTheory3 Cards.scientificTheory3 $ (healthL ?~ 1) . (sanityL ?~ 3)

instance HasAbilities ScientificTheory3 where
  getAbilities (ScientificTheory3 x) =
    [ wantsSkillTest (YourSkillTest $ oneOf [#intellect, #combat])
        $ controlledAbility x 1 (DuringSkillTest AnySkillTest) (FastAbility $ ResourceCost 1)
    ]

instance HasModifiersFor ScientificTheory3 where
  getModifiersFor target (ScientificTheory3 attrs) | attrs `is` target = do
    toModifiers attrs [NonDirectHorrorMustBeAssignToThisFirst, NonDirectDamageMustBeAssignToThisFirst]
  getModifiersFor (InvestigatorTarget iid) (ScientificTheory3 attrs) | iid `controls` attrs = do
    toModifiers attrs [SkillModifier #intellect 1, SkillModifier #combat 1]
  getModifiersFor _ _ = pure []

instance RunMessage ScientificTheory3 where
  runMessage msg a@(ScientificTheory3 attrs) = runQueueT $ case msg of
    UseThisAbility iid (isSource attrs -> True) 1 -> do
      withSkillTest \sid ->
        chooseOneM iid do
          skillLabeled #intellect $ skillTestModifier sid (attrs.ability 1) iid (SkillModifier #intellect 1)
          skillLabeled #combat $ skillTestModifier sid (attrs.ability 1) iid (SkillModifier #combat 1)
      pure a
    _ -> ScientificTheory3 <$> liftRunMessage msg attrs
