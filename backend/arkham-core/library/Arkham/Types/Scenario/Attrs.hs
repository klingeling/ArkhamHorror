module Arkham.Types.Scenario.Attrs
  ( module Arkham.Types.Scenario.Attrs
  , module X
  )
where

import Arkham.Import hiding (log)

import Arkham.Types.ScenarioLogKey
import Arkham.Types.Difficulty
import Arkham.Types.Scenario.Deck as X
import Arkham.Types.Scenario.Runner
import Arkham.Types.Location as X

newtype GridTemplateRow = GridTemplateRow { unGridTemplateRow :: Text }
  deriving newtype (Show, IsString, ToJSON, FromJSON)

data Attrs = Attrs
  { scenarioName        :: Text
  , scenarioId          :: ScenarioId
  , scenarioDifficulty  :: Difficulty
  -- These types are to handle complex scenarios with multiple stacks
  , scenarioAgendaStack :: [(Int, [AgendaId])] -- These types are to handle complex scenarios with multiple stacks
  , scenarioActStack    :: [(Int, [ActId])]
  , scenarioLocationLayout :: Maybe [GridTemplateRow]
  , scenarioDeck :: Maybe ScenarioDeck
  , scenarioLog :: HashSet ScenarioLogKey
  , scenarioLocations :: HashMap LocationName [LocationId]
  , scenarioSetAsideCards :: [Card]
  }
  deriving stock (Show, Generic)

instance ToJSON Attrs where
  toJSON = genericToJSON $ aesonOptions $ Just "scenario"
  toEncoding = genericToEncoding $ aesonOptions $ Just "scenario"

instance FromJSON Attrs where
  parseJSON = genericParseJSON $ aesonOptions $ Just "scenario"

toTokenValue :: Attrs -> Token -> Int -> Int -> TokenValue
toTokenValue attrs t esVal heVal = TokenValue
  t
  (NegativeModifier $ if isEasyStandard attrs then esVal else heVal)

isEasyStandard :: Attrs -> Bool
isEasyStandard Attrs { scenarioDifficulty } =
  scenarioDifficulty `elem` [Easy, Standard]

isHardExpert :: Attrs -> Bool
isHardExpert Attrs { scenarioDifficulty } =
  scenarioDifficulty `elem` [Hard, Expert]

actStackL :: Lens' Attrs [(Int, [ActId])]
actStackL = lens scenarioActStack $ \m x -> m { scenarioActStack = x }

locationsL :: Lens' Attrs (HashMap LocationName [LocationId])
locationsL = lens scenarioLocations $ \m x -> m { scenarioLocations = x }

setAsideCardsL :: Lens' Attrs [Card]
setAsideCardsL =
  lens scenarioSetAsideCards $ \m x -> m { scenarioSetAsideCards = x }

deckL :: Lens' Attrs (Maybe ScenarioDeck)
deckL = lens scenarioDeck $ \m x -> m { scenarioDeck = x }

logL :: Lens' Attrs (HashSet ScenarioLogKey)
logL = lens scenarioLog $ \m x -> m { scenarioLog = x }

baseAttrs :: CardCode -> Text -> [AgendaId] -> [ActId] -> Difficulty -> Attrs
baseAttrs cardCode name agendaStack actStack' difficulty = Attrs
  { scenarioId = ScenarioId cardCode
  , scenarioName = name
  , scenarioDifficulty = difficulty
  , scenarioAgendaStack = [(1, agendaStack)]
  , scenarioActStack = [(1, actStack')]
  , scenarioLocationLayout = Nothing
  , scenarioDeck = Nothing
  , scenarioLog = mempty
  , scenarioLocations = mempty
  , scenarioSetAsideCards = mempty
  }

instance Entity Attrs where
  type EntityId Attrs = ScenarioId
  toId = scenarioId
  toSource = ScenarioSource . toId
  toTarget = ScenarioTarget . toId
  isSource Attrs { scenarioId } (ScenarioSource sid) = scenarioId == sid
  isSource _ _ = False
  isTarget Attrs { scenarioId } (ScenarioTarget sid) = scenarioId == sid
  isTarget _ _ = False

instance HasTokenValue env InvestigatorId => HasTokenValue env Attrs where
  getTokenValue _ iid = \case
    ElderSign -> getTokenValue iid iid ElderSign
    AutoFail -> pure $ TokenValue AutoFail AutoFailModifier
    PlusOne -> pure $ TokenValue PlusOne (PositiveModifier 1)
    Zero -> pure $ TokenValue Zero (PositiveModifier 0)
    MinusOne -> pure $ TokenValue MinusOne (NegativeModifier 1)
    MinusTwo -> pure $ TokenValue MinusTwo (NegativeModifier 2)
    MinusThree -> pure $ TokenValue MinusThree (NegativeModifier 3)
    MinusFour -> pure $ TokenValue MinusFour (NegativeModifier 4)
    MinusFive -> pure $ TokenValue MinusFive (NegativeModifier 5)
    MinusSix -> pure $ TokenValue MinusSix (NegativeModifier 6)
    MinusSeven -> pure $ TokenValue MinusSeven (NegativeModifier 7)
    MinusEight -> pure $ TokenValue MinusEight (NegativeModifier 8)
    otherFace -> pure $ TokenValue otherFace NoModifier

findLocationKey
  :: LocationMatcher -> HashMap LocationName [LocationId] -> Maybe LocationName
findLocationKey locationMatcher locations = find matchKey $ keys locations
 where
  matchKey (LocationName (Name title msubtitle)) = case locationMatcher of
    LocationWithTitle title' -> title == title'
    LocationWithFullTitle title' subtitle' ->
      title == title' && Just subtitle' == msubtitle


instance ScenarioRunner env => RunMessage env Attrs where
  runMessage msg a@Attrs {..} = case msg of
    Setup -> a <$ pushMessage BeginInvestigation
    PlaceLocationMatching locationMatcher -> do
      let
        locations =
          fromMaybe []
            $ findLocationKey locationMatcher scenarioLocations
            >>= flip lookup scenarioLocations
      a <$ case locations of
        [] -> error "There were no locations with that name"
        [lid] -> unshiftMessage (PlaceLocation lid)
        _ ->
          error "We want there to be only one location when targetting names"
    EnemySpawnAtLocationMatching miid locationMatcher eid -> do
      let
        locations =
          fromMaybe []
            $ findLocationKey locationMatcher scenarioLocations
            >>= flip lookup scenarioLocations
      a <$ case locations of
        [] -> error "There were no locations with that name"
        [lid] -> unshiftMessage (EnemySpawn miid lid eid)
        _ ->
          error "We want there to be only one location when targetting names"
    PlaceDoomOnAgenda -> do
      agendaIds <- getSetList @AgendaId ()
      case agendaIds of
        [] -> pure a
        [x] -> a <$ unshiftMessage (PlaceDoom (AgendaTarget x) 1)
        _ -> error "multiple agendas should be handled by the scenario"
    Discard (ActTarget _) -> pure $ a & actStackL .~ []
    -- ^ See: Vengeance Awaits / The Devourer Below - right now the assumption
    -- | is that the act deck has been replaced.
    InvestigatorDefeated _ -> do
      investigatorIds <- getSet @InScenarioInvestigatorId ()
      if null investigatorIds then a <$ unshiftMessage NoResolution else pure a
    AllInvestigatorsResigned -> a <$ unshiftMessage NoResolution
    InvestigatorWhenEliminated iid ->
      a <$ unshiftMessage (InvestigatorEliminated iid)
    Remember logKey -> pure $ a & logL %~ insertSet logKey
    ResolveToken _drawnToken token _iid | token == AutoFail ->
      a <$ unshiftMessage FailSkillTest
    NoResolution ->
      error "The scenario should specify what to do for no resolution"
    Resolution _ ->
      error "The scenario should specify what to do for the resolution"
    UseScenarioSpecificAbility{} ->
      error
        "The scenario should specify what to do for a scenario specific ability."
    _ -> pure a
