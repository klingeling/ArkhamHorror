module Arkham.Agenda.Sequence where

import Arkham.Prelude

import Arkham.AgendaId

agendaStep :: AgendaSequence -> AgendaStep
agendaStep (Agenda num _) = AgendaStep num

agendaSide :: AgendaSequence -> AgendaSide
agendaSide (Agenda _ side) = side

data AgendaSide = A | B | C | D
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)

data AgendaSequence = Agenda Int AgendaSide
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)
