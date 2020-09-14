{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Agenda
  ( Agenda(..)
  , lookupAgenda
  )
where

import Arkham.Json
import Arkham.Types.Agenda.Attrs
import Arkham.Types.Agenda.Cards.PredatorOrPrey
import Arkham.Types.Agenda.Cards.RiseOfTheGhouls
import Arkham.Types.Agenda.Cards.TheArkhamWoods
import Arkham.Types.Agenda.Cards.TheRitualBegins
import Arkham.Types.Agenda.Cards.TheyreGettingOut
import Arkham.Types.Agenda.Cards.TimeIsRunningShort
import Arkham.Types.Agenda.Cards.VengeanceAwaits
import Arkham.Types.Agenda.Cards.WhatsGoingOn
import Arkham.Types.Agenda.Runner
import Arkham.Types.AgendaId
import Arkham.Types.Classes
import Arkham.Types.Query
import ClassyPrelude
import Data.Coerce
import qualified Data.HashMap.Strict as HashMap
import Safe (fromJustNote)

lookupAgenda :: AgendaId -> Agenda
lookupAgenda = fromJustNote "Unknown agenda" . flip HashMap.lookup allAgendas

allAgendas :: HashMap AgendaId Agenda
allAgendas = HashMap.fromList $ map
  (\a -> (agendaId $ agendaAttrs a, a))
  [ WhatsGoingOn' whatsGoingOn
  , RiseOfTheGhouls' riseOfTheGhouls
  , TheyreGettingOut' theyreGettingOut
  , PredatorOrPrey' predatorOrPrey
  , TimeIsRunningShort' timeIsRunningShort
  , TheArkhamWoods' theArkhamWoods
  , TheRitualBegins' theRitualBegins
  , VengeanceAwaits' vengeanceAwaits
  ]

instance HasAbilities Agenda where
  getAbilities = agendaAbilities . agendaAttrs

instance HasCount DoomCount () Agenda where
  getCount _ = DoomCount . agendaDoom . agendaAttrs

data Agenda
  = WhatsGoingOn' WhatsGoingOn
  | RiseOfTheGhouls' RiseOfTheGhouls
  | TheyreGettingOut' TheyreGettingOut
  | PredatorOrPrey' PredatorOrPrey
  | TimeIsRunningShort' TimeIsRunningShort
  | TheArkhamWoods' TheArkhamWoods
  | TheRitualBegins' TheRitualBegins
  | VengeanceAwaits' VengeanceAwaits
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON)

agendaAttrs :: Agenda -> Attrs
agendaAttrs = \case
  WhatsGoingOn' attrs -> coerce attrs
  RiseOfTheGhouls' attrs -> coerce attrs
  TheyreGettingOut' attrs -> coerce attrs
  PredatorOrPrey' attrs -> coerce attrs
  TimeIsRunningShort' attrs -> coerce attrs
  TheArkhamWoods' attrs -> coerce attrs
  TheRitualBegins' attrs -> coerce attrs
  VengeanceAwaits' attrs -> coerce attrs

deriving anyclass instance (ActionRunner env investigator) => HasActions env investigator Agenda
deriving anyclass instance (AgendaRunner env) => RunMessage env Agenda
