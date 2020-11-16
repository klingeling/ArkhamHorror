{-# LANGUAGE UndecidableInstances #-}
module Arkham.Types.Event.Cards.Lucky where

import Arkham.Import

import Arkham.Types.Event.Attrs
import Arkham.Types.Event.Runner

newtype Lucky = Lucky Attrs
  deriving newtype (Show, ToJSON, FromJSON)

lucky :: InvestigatorId -> EventId -> Lucky
lucky iid uuid = Lucky $ baseAttrs iid uuid "01080"

instance HasModifiersFor env Lucky where
  getModifiersFor = noModifiersFor

instance HasActions env Lucky where
  getActions i window (Lucky attrs) = getActions i window attrs

instance (EventRunner env) => RunMessage env Lucky where
  runMessage msg e@(Lucky attrs@Attrs {..}) = case msg of
    InvestigatorPlayEvent iid eid _ | eid == eventId -> e <$ unshiftMessages
      [ Discard (EventTarget eid)
      , CreateEffect "01080" Nothing (EventSource eid) (InvestigatorTarget iid)
      ]
    _ -> Lucky <$> runMessage msg attrs
