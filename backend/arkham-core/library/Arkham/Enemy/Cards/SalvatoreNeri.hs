module Arkham.Enemy.Cards.SalvatoreNeri
  ( salvatoreNeri
  , SalvatoreNeri(..)
  ) where

import Arkham.Prelude

import Arkham.Classes
import Arkham.Enemy.Cards qualified as Cards
import Arkham.Enemy.Runner hiding ( EnemyEvade )
import Arkham.Helpers.Investigator
import Arkham.Modifier qualified as Modifier
import Arkham.SkillType
import Arkham.Source
import Arkham.Target

newtype SalvatoreNeri = SalvatoreNeri EnemyAttrs
  deriving anyclass IsEnemy
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity, HasAbilities)

salvatoreNeri :: EnemyCard SalvatoreNeri
salvatoreNeri = enemy SalvatoreNeri Cards.salvatoreNeri (0, Static 3, 0) (0, 2)

instance HasModifiersFor SalvatoreNeri where
  getModifiersFor (InvestigatorSource iid) (EnemyTarget eid) (SalvatoreNeri attrs)
    | eid == toId attrs
    = do
      fightValue <- getSkillValue SkillCombat iid
      evadeValue <- getSkillValue SkillAgility iid
      pure $ toModifiers
        attrs
        [Modifier.EnemyFight fightValue, Modifier.EnemyEvade evadeValue]
  getModifiersFor _ _ _ = pure []

instance RunMessage SalvatoreNeri where
  runMessage msg (SalvatoreNeri attrs) = SalvatoreNeri <$> runMessage msg attrs
