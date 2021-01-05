module Arkham.Types.Treachery.Cards.OnWingsOfDarkness where

import Arkham.Import

import Arkham.Types.Trait
import Arkham.Types.Treachery.Attrs
import Arkham.Types.Treachery.Runner

newtype OnWingsOfDarkness = OnWingsOfDarkness Attrs
  deriving newtype (Show, ToJSON, FromJSON)

onWingsOfDarkness :: TreacheryId -> a -> OnWingsOfDarkness
onWingsOfDarkness uuid _ = OnWingsOfDarkness $ baseAttrs uuid "01173"

instance HasModifiersFor env OnWingsOfDarkness where
  getModifiersFor = noModifiersFor

instance HasActions env OnWingsOfDarkness where
  getActions i window (OnWingsOfDarkness attrs) = getActions i window attrs

instance TreacheryRunner env => RunMessage env OnWingsOfDarkness where
  runMessage msg t@(OnWingsOfDarkness attrs@Attrs {..}) = case msg of
    Revelation iid source | isSource attrs source -> do
      t <$ unshiftMessages
        [ RevelationSkillTest iid source SkillAgility 4
        , Discard (toTarget attrs)
        ]
    FailedSkillTest iid _ source SkillTestInitiatorTarget{} _
      | isSource attrs source -> do
        centralLocations <- getSetList [Central]
        t <$ unshiftMessages
          ([ InvestigatorAssignDamage iid source 1 1
           , UnengageNonMatching iid [Nightgaunt]
           ]
          <> [ Ask iid $ ChooseOne
                 [ MoveTo iid lid | lid <- centralLocations ]
             ]
          )
    _ -> OnWingsOfDarkness <$> runMessage msg attrs
