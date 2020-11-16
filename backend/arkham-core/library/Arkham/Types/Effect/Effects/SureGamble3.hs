module Arkham.Types.Effect.Effects.SureGamble3
  ( sureGamble3
  , SureGamble3(..)
  )
where

import Arkham.Import

import Arkham.Types.Effect.Attrs

newtype SureGamble3 = SureGamble3 Attrs
  deriving newtype (Show, ToJSON, FromJSON)

sureGamble3 :: EffectArgs -> SureGamble3
sureGamble3 = SureGamble3 . uncurry4 (baseAttrs "01088")

instance HasModifiersFor env SureGamble3 where
  getModifiersFor _ target (SureGamble3 Attrs {..}) | target == effectTarget =
    pure [NegativeToPositive]
  getModifiersFor _ _ _ = pure []

instance HasQueue env => RunMessage env SureGamble3 where
  runMessage msg e@(SureGamble3 attrs) = case msg of
    SkillTestEnds -> e <$ unshiftMessage (DisableEffect $ effectId attrs)
    _ -> SureGamble3 <$> runMessage msg attrs
