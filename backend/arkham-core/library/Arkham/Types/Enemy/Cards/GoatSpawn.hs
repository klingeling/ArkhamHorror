module Arkham.Types.Enemy.Cards.GoatSpawn where

import Arkham.Import

import Arkham.Types.Enemy.Attrs
import Arkham.Types.Enemy.Runner

newtype GoatSpawn = GoatSpawn Attrs
  deriving newtype (Show, ToJSON, FromJSON)

goatSpawn :: EnemyId -> GoatSpawn
goatSpawn uuid =
  GoatSpawn
    $ baseAttrs uuid "01180"
    $ (healthDamageL .~ 1)
    . (fightL .~ 3)
    . (healthL .~ Static 3)
    . (evadeL .~ 2)

instance HasModifiersFor env GoatSpawn where
  getModifiersFor = noModifiersFor

instance ActionRunner env => HasActions env GoatSpawn where
  getActions i window (GoatSpawn attrs) = getActions i window attrs

instance (EnemyRunner env) => RunMessage env GoatSpawn where
  runMessage msg (GoatSpawn attrs@Attrs {..}) = case msg of
    EnemyDefeated eid _ _ _ _ _ | eid == enemyId -> do
      investigatorIds <- getSetList enemyLocation
      unshiftMessages
        [ InvestigatorAssignDamage iid (EnemySource eid) 0 1
        | iid <- investigatorIds
        ]
      GoatSpawn <$> runMessage msg attrs
    _ -> GoatSpawn <$> runMessage msg attrs
