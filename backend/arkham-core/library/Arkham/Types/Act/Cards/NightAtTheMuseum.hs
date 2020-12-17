{-# LANGUAGE UndecidableInstances #-}

module Arkham.Types.Act.Cards.NightAtTheMuseum
  ( NightAtTheMuseum(..)
  , nightAtTheMuseum
  )
where

import Arkham.Import

import Arkham.Types.Act.Attrs
import Arkham.Types.Act.Helpers
import Arkham.Types.Act.Runner
import Arkham.Types.Card.EncounterCardMatcher

newtype NightAtTheMuseum = NightAtTheMuseum Attrs
  deriving newtype (Show, ToJSON, FromJSON)

nightAtTheMuseum :: NightAtTheMuseum
nightAtTheMuseum =
  NightAtTheMuseum $ baseAttrs "02123" "Night at the Museum" (Act 2 A) Nothing

instance ActionRunner env => HasActions env NightAtTheMuseum where
  getActions i window (NightAtTheMuseum x) = getActions i window x

instance ActRunner env => RunMessage env NightAtTheMuseum where
  runMessage msg a@(NightAtTheMuseum attrs@Attrs {..}) = case msg of
    AdvanceAct aid _ | aid == actId && actSequence == Act 2 A -> do
      leadInvestigatorId <- getLeadInvestigatorId
      unshiftMessage
        (chooseOne leadInvestigatorId [AdvanceAct aid (toSource attrs)])
      pure
        $ NightAtTheMuseum
        $ attrs
        & (sequenceL .~ Act 2 B)
        & (flippedL .~ True)
    AdvanceAct aid _ | aid == actId && actSequence == Act 2 B -> do
      leadInvestigatorId <- getLeadInvestigatorId
      a <$ unshiftMessage
        (FindEncounterCard
          leadInvestigatorId
          (toTarget attrs)
          (EncounterCardMatchByCardCode "02141")
        )
    FoundEnemyInVoid _ eid -> do
      lid <- fromJustNote "Exhibit Hall (Restricted Hall) missing"
        <$> getId (LocationName "Restricted Hall")
      a <$ unshiftMessages [EnemySpawn Nothing lid eid, NextAct actId "02125"]
    FoundEncounterCard _ target ec | isTarget attrs target -> do
      lid <- fromJustNote "Exibit Hall (Restricted Hall) missing"
        <$> getId (LocationName "Restricted Hall")
      a <$ unshiftMessages
        [SpawnEnemyAt (EncounterCard ec) lid, NextAct actId "02125"]
    WhenEnterLocation _ "02137" ->
      a <$ unshiftMessage (AdvanceAct actId (toSource attrs))
    _ -> NightAtTheMuseum <$> runMessage msg attrs
