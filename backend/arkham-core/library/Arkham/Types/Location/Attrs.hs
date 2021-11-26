module Arkham.Types.Location.Attrs
  ( module Arkham.Types.Location.Attrs
  , module X
  ) where

import Arkham.Prelude

import Arkham.Json
import Arkham.Location.Cards
import Arkham.Types.Ability
import Arkham.Types.Action qualified as Action
import Arkham.Types.Card
import Arkham.Types.Card.CardDef as X
import Arkham.Types.Classes as X
import Arkham.Types.Cost
import Arkham.Types.Criteria
import Arkham.Types.Direction
import Arkham.Types.Exception
import Arkham.Types.GameValue
import Arkham.Types.Id
import Arkham.Types.Location.Helpers
import Arkham.Types.Location.Runner as X
import Arkham.Types.LocationSymbol as X
import Arkham.Types.Matcher (LocationMatcher(..))
import Arkham.Types.Message
import Arkham.Types.Modifier
import Arkham.Types.Name
import Arkham.Types.Query
import Arkham.Types.SkillType
import Arkham.Types.Source
import Arkham.Types.Target
import Arkham.Types.Timing qualified as Timing
import Arkham.Types.Trait
import Arkham.Types.Window (Window(..))
import Arkham.Types.Window qualified as Window

class IsLocation a

pattern AfterFailedInvestigate :: InvestigatorId -> Target -> Message
pattern AfterFailedInvestigate iid target <-
  After (FailedSkillTest iid (Just Action.Investigate) _ target _ _)

pattern UseResign :: InvestigatorId -> Source -> Message
pattern UseResign iid source <- UseCardAbility iid source _ 99 _

pattern UseDrawCardUnderneath :: InvestigatorId -> Source -> Message
pattern UseDrawCardUnderneath iid source <- UseCardAbility iid source _ 100 _

type LocationCard a = CardBuilder LocationId a

data LocationAttrs = LocationAttrs
  { locationId :: LocationId
  , locationCardCode :: CardCode
  , locationLabel :: Text
  , locationRevealClues :: GameValue Int
  , locationClues :: Int
  , locationDoom :: Int
  , locationHorror :: Int
  , locationResources :: Int
  , locationShroud :: Int
  , locationRevealed :: Bool
  , locationInvestigators :: HashSet InvestigatorId
  , locationEnemies :: HashSet EnemyId
  , locationSymbol :: LocationSymbol
  , locationRevealedSymbol :: LocationSymbol
  , locationConnectedMatchers :: [LocationMatcher]
  , locationRevealedConnectedMatchers :: [LocationMatcher]
  , locationTreacheries :: HashSet TreacheryId
  , locationEvents :: HashSet EventId
  , locationAssets :: HashSet AssetId
  , locationDirections :: HashMap Direction LocationId
  , locationConnectsTo :: HashSet Direction
  , locationCardsUnderneath :: [Card]
  , locationCostToEnterUnrevealed :: Cost
  }
  deriving stock (Show, Eq, Generic)

symbolL :: Lens' LocationAttrs LocationSymbol
symbolL = lens locationSymbol $ \m x -> m { locationSymbol = x }

costToEnterUnrevealedL :: Lens' LocationAttrs Cost
costToEnterUnrevealedL = lens locationCostToEnterUnrevealed
  $ \m x -> m { locationCostToEnterUnrevealed = x }

connectsToL :: Lens' LocationAttrs (HashSet Direction)
connectsToL = lens locationConnectsTo $ \m x -> m { locationConnectsTo = x }

connectedMatchersL :: Lens' LocationAttrs [LocationMatcher]
connectedMatchersL =
  lens locationConnectedMatchers $ \m x -> m { locationConnectedMatchers = x }

revealedConnectedMatchersL :: Lens' LocationAttrs [LocationMatcher]
revealedConnectedMatchersL = lens locationRevealedConnectedMatchers
  $ \m x -> m { locationRevealedConnectedMatchers = x }

revealedSymbolL :: Lens' LocationAttrs LocationSymbol
revealedSymbolL =
  lens locationRevealedSymbol $ \m x -> m { locationRevealedSymbol = x }

labelL :: Lens' LocationAttrs Text
labelL = lens locationLabel $ \m x -> m { locationLabel = x }

treacheriesL :: Lens' LocationAttrs (HashSet TreacheryId)
treacheriesL = lens locationTreacheries $ \m x -> m { locationTreacheries = x }

eventsL :: Lens' LocationAttrs (HashSet EventId)
eventsL = lens locationEvents $ \m x -> m { locationEvents = x }

investigatorsL :: Lens' LocationAttrs (HashSet InvestigatorId)
investigatorsL =
  lens locationInvestigators $ \m x -> m { locationInvestigators = x }

enemiesL :: Lens' LocationAttrs (HashSet EnemyId)
enemiesL = lens locationEnemies $ \m x -> m { locationEnemies = x }

assetsL :: Lens' LocationAttrs (HashSet AssetId)
assetsL = lens locationAssets $ \m x -> m { locationAssets = x }

doomL :: Lens' LocationAttrs Int
doomL = lens locationDoom $ \m x -> m { locationDoom = x }

horrorL :: Lens' LocationAttrs Int
horrorL = lens locationHorror $ \m x -> m { locationHorror = x }

cluesL :: Lens' LocationAttrs Int
cluesL = lens locationClues $ \m x -> m { locationClues = x }

resourcesL :: Lens' LocationAttrs Int
resourcesL = lens locationResources $ \m x -> m { locationResources = x }

revealedL :: Lens' LocationAttrs Bool
revealedL = lens locationRevealed $ \m x -> m { locationRevealed = x }

directionsL :: Lens' LocationAttrs (HashMap Direction LocationId)
directionsL = lens locationDirections $ \m x -> m { locationDirections = x }

cardsUnderneathL :: Lens' LocationAttrs [Card]
cardsUnderneathL =
  lens locationCardsUnderneath $ \m x -> m { locationCardsUnderneath = x }

instance HasCardCode LocationAttrs where
  toCardCode = locationCardCode

instance HasCardDef LocationAttrs where
  toCardDef a = case lookup (locationCardCode a) allLocationCards of
    Just def -> def
    Nothing ->
      error $ "missing card def for location " <> show (locationCardCode a)

instance ToJSON LocationAttrs where
  toJSON = genericToJSON $ aesonOptions $ Just "location"
  toEncoding = genericToEncoding $ aesonOptions $ Just "location"

instance FromJSON LocationAttrs where
  parseJSON = genericParseJSON $ aesonOptions $ Just "location"

instance Entity LocationAttrs where
  type EntityId LocationAttrs = LocationId
  type EntityAttrs LocationAttrs = LocationAttrs
  toId = locationId
  toAttrs = id

instance Named LocationAttrs where
  toName l = if locationRevealed l
    then fromMaybe baseName (cdRevealedName $ toCardDef l)
    else baseName
    where baseName = toName (toCardDef l)

instance Named (Unrevealed LocationAttrs) where
  toName (Unrevealed l) = toName (toCardDef l)

instance TargetEntity LocationAttrs where
  toTarget = LocationTarget . toId
  isTarget LocationAttrs { locationId } (LocationTarget lid) =
    locationId == lid
  isTarget attrs (SkillTestInitiatorTarget target) = isTarget attrs target
  isTarget _ _ = False

instance SourceEntity LocationAttrs where
  toSource = LocationSource . toId
  isSource LocationAttrs { locationId } (LocationSource lid) =
    locationId == lid
  isSource LocationAttrs { locationId } (ProxySource (LocationSource lid) _) =
    locationId == lid
  isSource _ _ = False

instance IsCard LocationAttrs where
  toCardId = unLocationId . locationId

instance HasName env LocationAttrs where
  getName = pure . toName

instance HasName env (Unrevealed LocationAttrs) where
  getName = pure . toName

instance HasId (Maybe LocationId) env (Direction, LocationAttrs) where
  getId (dir, LocationAttrs {..}) = pure $ lookup dir locationDirections

instance HasId LocationSymbol env LocationAttrs where
  getId = pure . locationSymbol

instance HasList UnderneathCard env LocationAttrs where
  getList = pure . map UnderneathCard . locationCardsUnderneath

unrevealed :: LocationAttrs -> Bool
unrevealed = not . locationRevealed

revealed :: LocationAttrs -> Bool
revealed = locationRevealed

location
  :: (LocationAttrs -> a)
  -> CardDef
  -> Int
  -> GameValue Int
  -> LocationSymbol
  -> [LocationSymbol]
  -> CardBuilder LocationId a
location f def shroud' revealClues symbol' connectedSymbols' =
  locationWith f def shroud' revealClues symbol' connectedSymbols' id

locationWithRevealedSideConnections
  :: (LocationAttrs -> a)
  -> CardDef
  -> Int
  -> GameValue Int
  -> LocationSymbol
  -> [LocationSymbol]
  -> LocationSymbol
  -> [LocationSymbol]
  -> CardBuilder LocationId a
locationWithRevealedSideConnections f def shroud' revealClues symbol' connectedSymbols' revealedSymbol' revealedConnectedSymbols'
  = locationWithRevealedSideConnectionsWith
    f
    def
    shroud'
    revealClues
    symbol'
    connectedSymbols'
    revealedSymbol'
    revealedConnectedSymbols'
    id

locationWithRevealedSideConnectionsWith
  :: (LocationAttrs -> a)
  -> CardDef
  -> Int
  -> GameValue Int
  -> LocationSymbol
  -> [LocationSymbol]
  -> LocationSymbol
  -> [LocationSymbol]
  -> (LocationAttrs -> LocationAttrs)
  -> CardBuilder LocationId a
locationWithRevealedSideConnectionsWith f def shroud' revealClues symbol' connectedSymbols' revealedSymbol' revealedConnectedSymbols' g
  = locationWith
    f
    def
    shroud'
    revealClues
    symbol'
    connectedSymbols'
    (g
    . (revealedConnectedMatchersL
      <>~ map LocationWithSymbol revealedConnectedSymbols'
      )
    . (revealedSymbolL .~ revealedSymbol')
    )

locationWith
  :: (LocationAttrs -> a)
  -> CardDef
  -> Int
  -> GameValue Int
  -> LocationSymbol
  -> [LocationSymbol]
  -> (LocationAttrs -> LocationAttrs)
  -> CardBuilder LocationId a
locationWith f def shroud' revealClues symbol' connectedSymbols' g =
  CardBuilder
    { cbCardCode = cdCardCode def
    , cbCardBuilder = \lid -> f . g $ LocationAttrs
      { locationId = lid
      , locationCardCode = toCardCode def
      , locationLabel = nameToLabel (cdName def)
      , locationRevealClues = revealClues
      , locationClues = 0
      , locationHorror = 0
      , locationDoom = 0
      , locationResources = 0
      , locationShroud = shroud'
      , locationRevealed = False
      , locationInvestigators = mempty
      , locationEnemies = mempty
      , locationSymbol = symbol'
      , locationRevealedSymbol = symbol'
      , locationConnectedMatchers = map LocationWithSymbol connectedSymbols'
      , locationRevealedConnectedMatchers = map
        LocationWithSymbol
        connectedSymbols'
      , locationTreacheries = mempty
      , locationEvents = mempty
      , locationAssets = mempty
      , locationDirections = mempty
      , locationConnectsTo = mempty
      , locationCardsUnderneath = mempty
      , locationCostToEnterUnrevealed = ActionCost 1
      }
    }

locationEnemiesWithTrait
  :: (MonadReader env m, HasSet Trait env EnemyId)
  => LocationAttrs
  -> Trait
  -> m [EnemyId]
locationEnemiesWithTrait LocationAttrs { locationEnemies } trait =
  filterM (fmap (member trait) . getSet) (setToList locationEnemies)

locationInvestigatorsWithClues
  :: (MonadReader env m, HasCount ClueCount env InvestigatorId)
  => LocationAttrs
  -> m [InvestigatorId]
locationInvestigatorsWithClues LocationAttrs { locationInvestigators } =
  filterM
    (fmap ((> 0) . unClueCount) . getCount)
    (setToList locationInvestigators)

getModifiedShroudValueFor
  :: (MonadReader env m, HasModifiersFor env ()) => LocationAttrs -> m Int
getModifiedShroudValueFor attrs = do
  modifiers' <- getModifiers (toSource attrs) (toTarget attrs)
  pure $ foldr applyModifier (locationShroud attrs) modifiers'
 where
  applyModifier (ShroudModifier m) n = max 0 (n + m)
  applyModifier _ n = n

getInvestigateAllowed
  :: (MonadReader env m, HasModifiersFor env ())
  => InvestigatorId
  -> LocationAttrs
  -> m Bool
getInvestigateAllowed iid attrs = do
  modifiers1' <- getModifiers (toSource attrs) (toTarget attrs)
  modifiers2' <- getModifiers (InvestigatorSource iid) (toTarget attrs)
  pure $ not (any isCannotInvestigate $ modifiers1' <> modifiers2')
 where
  isCannotInvestigate CannotInvestigate{} = True
  isCannotInvestigate _ = False

canEnterLocation
  :: (LocationRunner env, MonadReader env m) => EnemyId -> LocationId -> m Bool
canEnterLocation eid lid = do
  traits' <- getSet eid
  modifiers' <- getModifiers (EnemySource eid) (LocationTarget lid)
  pure $ not $ flip any modifiers' $ \case
    CannotBeEnteredByNonElite{} -> Elite `notMember` traits'
    _ -> False

withResignAction
  :: (Entity location, EntityAttrs location ~ LocationAttrs)
  => location
  -> [Ability]
  -> [Ability]
withResignAction x body = do
  let other = withBaseAbilities attrs body
  locationResignAction attrs : other
  where attrs = toAttrs x

locationResignAction :: LocationAttrs -> Ability
locationResignAction attrs = toLocationAbility attrs (resignAction attrs)

toLocationAbility :: LocationAttrs -> Ability -> Ability
toLocationAbility attrs ability = ability
  { abilityCriteria = Just
    (fromMaybe mempty (abilityCriteria ability)
    <> OnLocation (LocationWithId $ toId attrs)
    )
  }

locationAbility :: Ability -> Ability
locationAbility ability = case abilitySource ability of
  LocationSource lid -> ability
    { abilityCriteria = Just
      (fromMaybe mempty (abilityCriteria ability)
      <> OnLocation (LocationWithId lid)
      )
    }
  _ -> ability

withDrawCardUnderneathAction
  :: (Entity location, EntityAttrs location ~ LocationAttrs)
  => location
  -> [Ability]
withDrawCardUnderneathAction x = withBaseAbilities
  attrs
  [ drawCardUnderneathAction attrs | locationRevealed attrs ]
  where attrs = toAttrs x

instance HasAbilities LocationAttrs where
  getAbilities l =
    [ restrictedAbility l 101 (OnLocation $ LocationWithId $ toId l)
      $ ActionAbility (Just Action.Investigate) (ActionCost 1)
    , restrictedAbility
        l
        102
        (OnLocation $ AccessibleTo $ LocationWithId $ toId l)
      $ ActionAbility (Just Action.Move) moveCost
    ]
   where
    moveCost = if not (locationRevealed l)
      then locationCostToEnterUnrevealed l
      else ActionCost 1

getShouldSpawnNonEliteAtConnectingInstead
  :: (MonadReader env m, HasModifiersFor env ()) => LocationAttrs -> m Bool
getShouldSpawnNonEliteAtConnectingInstead attrs = do
  modifiers' <- getModifiers (toSource attrs) (toTarget attrs)
  pure $ flip any modifiers' $ \case
    SpawnNonEliteAtConnectingInstead{} -> True
    _ -> False

on :: InvestigatorId -> LocationAttrs -> Bool
on iid LocationAttrs { locationInvestigators } =
  iid `member` locationInvestigators

instance LocationRunner env => RunMessage env LocationAttrs where
  runMessage msg a@LocationAttrs {..} = case msg of
    Investigate iid lid source mTarget skillType False | lid == locationId -> do
      allowed <- getInvestigateAllowed iid a
      if allowed
        then do
          shroudValue' <- getModifiedShroudValueFor a
          a <$ push
            (BeginSkillTest
              iid
              source
              (maybe
                (LocationTarget lid)
                (ProxyTarget (LocationTarget lid))
                mTarget
              )
              (Just Action.Investigate)
              skillType
              shroudValue'
            )
        else pure a
    PassedSkillTest iid (Just Action.Investigate) source (SkillTestInitiatorTarget target) _ n
      | isTarget a target
      -> a <$ push (Successful (Action.Investigate, target) iid source target n)
    PassedSkillTest iid (Just Action.Investigate) source (SkillTestInitiatorTarget (ProxyTarget target investigationTarget)) _ n
      | isTarget a target
      -> a
        <$ push
             (Successful
               (Action.Investigate, target)
               iid
               source
               investigationTarget
               n
             )
    Successful (Action.Investigate, _) iid _ target _ | isTarget a target -> do
      let lid = toId a
      modifiers' <- getModifiers (InvestigatorSource iid) (LocationTarget lid)
      whenWindowMsg <- checkWindows
        [Window Timing.When (Window.SuccessfulInvestigation iid lid)]
      afterWindowMsg <- checkWindows
        [Window Timing.After (Window.SuccessfulInvestigation iid lid)]
      a <$ unless
        (AlternateSuccessfullInvestigation `elem` modifiers')
        (pushAll
          [ whenWindowMsg
          , InvestigatorDiscoverClues iid lid 1 (Just Action.Investigate)
          , afterWindowMsg
          ]
        )
    PlaceUnderneath target cards | isTarget a target ->
      pure $ a & cardsUnderneathL <>~ cards
    SetLocationLabel lid label' | lid == locationId ->
      pure $ a & labelL .~ label'
    PlacedLocationDirection lid direction lid2 | lid == locationId -> do
      let
        reversedDirection = case direction of
          LeftOf -> RightOf
          RightOf -> LeftOf
          Above -> Below
          Below -> Above

      pure $ a & (directionsL %~ insertMap reversedDirection lid2)
    PlacedLocationDirection lid direction lid2 | lid2 == locationId ->
      pure $ a & (directionsL %~ insertMap direction lid)
    AttachTreachery tid (LocationTarget lid) | lid == locationId ->
      pure $ a & treacheriesL %~ insertSet tid
    AttachEvent eid (LocationTarget lid) | lid == locationId ->
      pure $ a & eventsL %~ insertSet eid
    Discarded (AssetTarget aid) _ -> pure $ a & assetsL %~ deleteSet aid
    Discard (TreacheryTarget tid) -> pure $ a & treacheriesL %~ deleteSet tid
    Discard (EventTarget eid) -> pure $ a & eventsL %~ deleteSet eid
    Discarded (EnemyTarget eid) _ -> pure $ a & enemiesL %~ deleteSet eid
    PlaceEnemyInVoid eid -> pure $ a & enemiesL %~ deleteSet eid
    Flipped (AssetSource aid) card | toCardType card /= AssetType ->
      pure $ a & assetsL %~ deleteSet aid
    RemoveFromGame (AssetTarget aid) -> pure $ a & assetsL %~ deleteSet aid
    RemoveFromGame (TreacheryTarget tid) ->
      pure $ a & treacheriesL %~ deleteSet tid
    RemoveFromGame (EventTarget eid) -> pure $ a & eventsL %~ deleteSet eid
    RemoveFromGame (EnemyTarget eid) -> pure $ a & enemiesL %~ deleteSet eid
    Discard target | isTarget a target ->
      a <$ pushAll (resolve (RemoveLocation $ toId a))
    AttachAsset aid (LocationTarget lid) | lid == locationId ->
      pure $ a & assetsL %~ insertSet aid
    AttachAsset aid _ -> pure $ a & assetsL %~ deleteSet aid
    AddDirectConnection fromLid toLid | fromLid == locationId -> do
      pure
        $ a
        & revealedConnectedMatchersL
        <>~ [LocationWithId toLid]
        & connectedMatchersL
        <>~ [LocationWithId toLid]
    DiscoverCluesAtLocation iid lid n maction | lid == locationId -> do
      let discoveredClues = min n locationClues
      checkWindowMsg <- checkWindows
        [Window Timing.When (Window.DiscoverClues iid lid discoveredClues)]
      a <$ pushAll
        [checkWindowMsg, DiscoverClues iid lid discoveredClues maction]
    Do (DiscoverClues iid lid n _) | lid == locationId -> do
      let lastClue = locationClues - n <= 0
      push =<< checkWindows
        (Window Timing.After (Window.DiscoverClues iid lid n)
        : [ Window Timing.After (Window.DiscoveringLastClue iid lid)
          | lastClue
          ]
        )
      pure $ a & cluesL %~ max 0 . subtract n
    InvestigatorEliminated iid -> pure $ a & investigatorsL %~ deleteSet iid
    EnterLocation iid lid
      | lid /= locationId && iid `elem` locationInvestigators
      -> pure $ a & investigatorsL %~ deleteSet iid -- TODO: should we broadcast leaving the location
    EnterLocation iid lid | lid == locationId -> do
      push =<< checkWindows [Window Timing.When $ Window.Entering iid lid]
      unless locationRevealed $ push (RevealLocation (Just iid) lid)
      pure $ a & investigatorsL %~ insertSet iid
    SetLocationAsIf iid lid | lid == locationId -> do
      pure $ a & investigatorsL %~ insertSet iid
    SetLocationAsIf iid lid | lid /= locationId -> do
      pure $ a & investigatorsL %~ deleteSet iid
    AddToVictory (EnemyTarget eid) -> pure $ a & enemiesL %~ deleteSet eid
    EnemyEngageInvestigator eid iid -> do
      lid <- getId @LocationId iid
      if lid == locationId then pure $ a & enemiesL %~ insertSet eid else pure a
    EnemyMove eid fromLid lid | fromLid == locationId -> do
      willMove <- canEnterLocation eid lid
      pure $ if willMove then a & enemiesL %~ deleteSet eid else a
    EnemyMove eid _ lid | lid == locationId -> do
      willMove <- canEnterLocation eid lid
      pure $ if willMove then a & enemiesL %~ insertSet eid else a
    EnemyEntered eid lid | lid == locationId -> do
      pure $ a & enemiesL %~ insertSet eid
    EnemyEntered eid lid | lid /= locationId -> do
      pure $ a & enemiesL %~ deleteSet eid
    Will next@(EnemySpawn miid lid eid) | lid == locationId -> do
      shouldSpawnNonEliteAtConnectingInstead <-
        getShouldSpawnNonEliteAtConnectingInstead a
      when shouldSpawnNonEliteAtConnectingInstead $ do
        traits' <- getSetList eid
        when (Elite `notElem` traits') $ do
          activeInvestigatorId <- unActiveInvestigatorId <$> getId ()
          connectedLocationIds <- map unConnectedLocationId <$> getSetList lid
          availableLocationIds <-
            flip filterM connectedLocationIds $ \locationId' -> do
              modifiers' <- getModifiers
                (EnemySource eid)
                (LocationTarget locationId')
              pure . not $ flip any modifiers' $ \case
                SpawnNonEliteAtConnectingInstead{} -> True
                _ -> False
          withQueue_ $ filter (/= next)
          if null availableLocationIds
            then push (Discard (EnemyTarget eid))
            else push
              (chooseOne
                activeInvestigatorId
                [ Run
                    [Will (EnemySpawn miid lid' eid), EnemySpawn miid lid' eid]
                | lid' <- availableLocationIds
                ]
              )
      pure a
    EnemySpawn _ lid eid | lid == locationId ->
      pure $ a & enemiesL %~ insertSet eid
    EnemySpawnedAt lid eid | lid == locationId ->
      pure $ a & enemiesL %~ insertSet eid
    RemoveEnemy eid -> pure $ a & enemiesL %~ deleteSet eid
    RemovedFromPlay (EnemySource eid) -> pure $ a & enemiesL %~ deleteSet eid
    TakeControlOfAsset _ aid -> pure $ a & assetsL %~ deleteSet aid
    MoveAllCluesTo target | not (isTarget a target) -> do
      when (locationClues > 0) (push $ PlaceClues target locationClues)
      pure $ a & cluesL .~ 0
    PlaceClues target n | isTarget a target -> do
      modifiers' <- getModifiers (toSource a) (toTarget a)
      windows' <- windows [Window.PlacedClues (toTarget a) n]
      if CannotPlaceClues `elem` modifiers'
        then pure a
        else do
          pushAll windows'
          pure $ a & cluesL +~ n
    PlaceCluesUpToClueValue lid n | lid == locationId -> do
      clueValue <- getPlayerCountValue locationRevealClues
      let n' = min n (clueValue - locationClues)
      a <$ push (PlaceClues (toTarget a) n')
    PlaceDoom target n | isTarget a target -> pure $ a & doomL +~ n
    RemoveDoom target n | isTarget a target ->
      pure $ a & doomL %~ max 0 . subtract n
    PlaceResources target n | isTarget a target -> pure $ a & resourcesL +~ n
    PlaceHorror target n | isTarget a target -> pure $ a & horrorL +~ n
    RemoveClues (LocationTarget lid) n | lid == locationId ->
      pure $ a & cluesL %~ max 0 . subtract n
    RemoveAllClues target | isTarget a target -> pure $ a & cluesL .~ 0
    RemoveAllDoom -> pure $ a & doomL .~ 0
    RevealLocation miid lid | lid == locationId -> do
      modifiers' <- getModifiers (toSource a) (toTarget a)
      locationClueCount <- if CannotPlaceClues `elem` modifiers'
        then pure 0
        else getPlayerCountValue locationRevealClues
      revealer <- maybe getLeadInvestigatorId pure miid
      whenWindowMsg <- checkWindows
        [Window Timing.When (Window.RevealLocation revealer lid)]

      afterWindowMsg <- checkWindows
        [Window Timing.After (Window.RevealLocation revealer lid)]
      pushAll
        $ [whenWindowMsg, afterWindowMsg]
        <> [ PlaceClues (toTarget a) locationClueCount | locationClueCount > 0 ]
      pure $ a & revealedL .~ True
    LookAtRevealed source target | isTarget a target -> do
      push (Label "Continue" [After (LookAtRevealed source target)])
      pure $ a & revealedL .~ True
    After (LookAtRevealed _ target) | isTarget a target ->
      pure $ a & revealedL .~ False
    UnrevealLocation lid | lid == locationId -> pure $ a & revealedL .~ False
    RemoveLocation lid -> pure $ a & directionsL %~ filterMap (/= lid)
    UseResign iid source | isSource a source -> a <$ push (Resign iid)
    UseDrawCardUnderneath iid source | isSource a source ->
      case locationCardsUnderneath of
        (EncounterCard card : rest) -> do
          push (InvestigatorDrewEncounterCard iid card)
          pure $ a & cardsUnderneathL .~ rest
        _ ->
          throwIO
            $ InvalidState
            $ "Not expecting a player card or empty set, but got "
            <> tshow locationCardsUnderneath
    Blanked msg' -> runMessage msg' a
    UseCardAbility iid source _ 101 _ | isSource a source -> do
      let
        triggerSource = case source of
          ProxySource _ s -> s
          _ -> InvestigatorSource iid
      a <$ push
        (Investigate iid (toId a) triggerSource Nothing SkillIntellect False)
    UseCardAbility iid source _ 102 _ | isSource a source -> a <$ push
      (MoveAction
        iid
        locationId
        Free -- already paid by using ability
        True
      )
    _ -> pure a
