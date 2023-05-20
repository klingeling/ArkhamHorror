module Arkham.Scenario.Scenarios.ThreadsOfFate (
  ThreadsOfFate (..),
  threadsOfFate,
) where

import Arkham.Prelude

import Arkham.Act qualified as Act
import Arkham.Act.Cards qualified as Acts
import Arkham.Act.Sequence qualified as Act
import Arkham.Act.Types (ActAttrs (actSequence))
import Arkham.Agenda.Cards qualified as Agendas
import Arkham.Asset.Cards qualified as Assets
import Arkham.CampaignLogKey
import Arkham.Card
import Arkham.Classes
import Arkham.Difficulty
import Arkham.EncounterSet qualified as EncounterSet
import Arkham.Enemy.Types (Field (..))
import Arkham.Helpers
import Arkham.Helpers.Card
import Arkham.Helpers.Log
import Arkham.Helpers.Query
import Arkham.Helpers.Scenario
import Arkham.Id
import Arkham.Location.Cards qualified as Locations
import Arkham.Matcher
import Arkham.Message
import Arkham.Scenario.Helpers
import Arkham.Scenario.Runner
import Arkham.ScenarioLogKey
import Arkham.Scenarios.ThreadsOfFate.Story
import Arkham.Token
import Arkham.Trait qualified as Trait
import Arkham.Treachery.Cards qualified as Treacheries
import Data.IntMap.Strict qualified as IntMap

newtype ThreadsOfFate = ThreadsOfFate ScenarioAttrs
  deriving anyclass (IsScenario, HasModifiersFor)
  deriving newtype (Show, Eq, ToJSON, FromJSON, Entity)

threadsOfFate :: Difficulty -> ThreadsOfFate
threadsOfFate difficulty =
  scenarioWith
    ThreadsOfFate
    "04113"
    "Threads of Fate"
    difficulty
    [ ".                .                trainTracks  trainTracks          townHall             townHall  arkhamPoliceStation  arkhamPoliceStation .           ."
    , "curiositieShoppe curiositieShoppe northside    northside            downtown             downtown  easttown             easttown            velmasDiner velmasDiner"
    , ".                eztliExhibit     eztliExhibit miskatonicUniversity miskatonicUniversity rivertown rivertown            blackCave           blackCave   ."
    ]
    (decksLayoutL .~ [". act1", "agenda1 act2", ". act3"])

instance HasTokenValue ThreadsOfFate where
  getTokenValue iid tokenFace (ThreadsOfFate attrs) = case tokenFace of
    Skull -> do
      n <- selectMax EnemyDoom (EnemyWithTrait Trait.Cultist)
      doom <- getDoomCount
      pure $ toTokenValue attrs Skull n doom
    Cultist -> pure $ toTokenValue attrs Cultist 2 2
    Tablet -> pure $ toTokenValue attrs Tablet 2 2
    ElderThing -> pure $ toTokenValue attrs ElderThing 2 3
    otherFace -> getTokenValue iid otherFace attrs

standaloneTokens :: [TokenFace]
standaloneTokens =
  [ PlusOne
  , Zero
  , Zero
  , Zero
  , MinusOne
  , MinusTwo
  , MinusTwo
  , MinusThree
  , MinusFive
  , Skull
  , Skull
  , Cultist
  , ElderThing
  , AutoFail
  , ElderSign
  ]

instance RunMessage ThreadsOfFate where
  runMessage msg s@(ThreadsOfFate attrs) = case msg of
    SetTokensForScenario -> do
      whenM getIsStandalone $ push $ SetTokens standaloneTokens
      pure s
    StandaloneSetup -> do
      leadInvestigatorId <- getLeadInvestigatorId
      push $
        chooseOne
          leadInvestigatorId
          [ Label
              "The investigators gave custody of the relic to Alejandro."
              [Record TheInvestigatorsGaveCustodyOfTheRelicToAlejandro]
          , Label
              "The investigators gave custody of the relic to Harlan Earnstone."
              [Record TheInvestigatorsGaveCustodyOfTheRelicToHarlanEarnstone]
          ]
      pure s
    Setup -> do
      iids <- allInvestigatorIds
      leadInvestigatorId <- getLeadInvestigatorId
      gaveCustodyToHarlan <-
        getHasRecord
          TheInvestigatorsGaveCustodyOfTheRelicToHarlanEarnstone
      let intro2or3 = if gaveCustodyToHarlan then intro3 else intro2
      pushAll
        [ story iids intro1
        , story iids intro2or3
        , chooseOne
            leadInvestigatorId
            [ Label
                "“You’re not going anywhere until you tell me what is going on.” - Skip to Intro 4."
                [SetupStep (toTarget attrs) 4]
            , Label
                "“Have it your way.” - Skip to Intro 5."
                [SetupStep (toTarget attrs) 5]
            ]
        ]
      pure s
    SetupStep target 7 | isTarget attrs target -> do
      -- Setup step 7 doesn't actually exist, but it is how
      gatheredCards <-
        buildEncounterDeck
          [ EncounterSet.ThreadsOfFate
          , EncounterSet.PnakoticBrotherhood
          , EncounterSet.LockedDoors
          , EncounterSet.Nightgaunts
          , EncounterSet.DarkCult
          ]
      midnightMasks <-
        traverse
          genEncounterCard
          [ Treacheries.huntingShadow
          , Treacheries.huntingShadow
          , Treacheries.huntingShadow
          , Treacheries.falseLead
          , Treacheries.falseLead
          ]
      encounterDeck <- Deck <$> shuffleM (unDeck gatheredCards <> midnightMasks)

      (rivertownId, placeRivertown) <- placeLocationCard Locations.rivertown
      placeOtherLocations <-
        traverse
          placeLocationCard_
          [ Locations.northside
          , Locations.downtownFirstBankOfArkham
          , Locations.easttown
          , Locations.miskatonicUniversity
          , Locations.velmasDiner
          , Locations.curiositieShoppe
          ]

      gaveCustodyToHarlan <-
        getHasRecord
          TheInvestigatorsGaveCustodyOfTheRelicToHarlanEarnstone

      act1Deck <-
        if gaveCustodyToHarlan
          then do
            harlansCurse <-
              sample $
                Acts.harlansCurseSafekeeping
                  :| [Acts.harlansCurseHarlanEarnstone]
            genCards
              [ Acts.harlanIsInDanger
              , harlansCurse
              , Acts.findTheRelic
              , Acts.recoverTheRelic
              ]
          else do
            atTheExhibit <-
              sample $
                Acts.atTheExhibitTheRelicsLocation
                  :| [Acts.atTheExhibitTheBrotherhoodsPlot]
            genCards
              [ Acts.theRelicIsMissing
              , atTheExhibit
              , Acts.findTheRelic
              , Acts.recoverTheRelic
              ]

      act2Deck1 <- do
        atTheStation <-
          sample $
            Acts.atTheStationInShadowedTalons
              :| [Acts.atTheStationTrainTracks]
        genCards
          [ Acts.missingPersons
          , atTheStation
          , Acts.alejandrosPrison
          , Acts.alejandrosPlight
          ]
      act2Deck2 <- do
        friendsInHighPlaces <-
          sample $
            Acts.friendsInHighPlacesHenrysInformation
              :| [Acts.friendsInHighPlacesHenryDeveau]
        genCards
          [ Acts.searchForAlejandro
          , friendsInHighPlaces
          , Acts.alejandrosPrison
          , Acts.alejandrosPlight
          ]

      listenedToIchtacasTale <- remembered YouListenedToIchtacasTale
      act3Deck <-
        if listenedToIchtacasTale
          then do
            strangeRelics <-
              sample $
                Acts.strangeRelicsMariaDeSilva
                  :| [Acts.strangeRelicsMariasInformation]
            genCards
              [ Acts.theGuardiansInquiry
              , strangeRelics
              , Acts.strangeOccurences
              , Acts.theBrotherhoodIsRevealed
              ]
          else do
            theCaveOfDarkness <-
              sample $
                Acts.theCaveOfDarknessEmbroiledInBattle
                  :| [Acts.theCaveOfDarknessTunnelsInTheDark]
            genCards
              [ Acts.trialOfTheHuntress
              , theCaveOfDarkness
              , Acts.strangeOccurences
              , Acts.theBrotherhoodIsRevealed
              ]
      leadInvestigatorId <- getLeadInvestigatorId
      setAsideCards <-
        genCards
          [ Locations.townHall
          , Assets.ichtacaTheForgottenGuardian
          , Assets.expeditionJournal
          , Assets.relicOfAgesADeviceOfSomeSort
          , Assets.alejandroVela
          ]

      pushAll $
        [ RemoveCampaignCard Assets.relicOfAgesADeviceOfSomeSort
        , RemoveCampaignCard Assets.alejandroVela
        , SetEncounterDeck encounterDeck
        , chooseOne
            leadInvestigatorId
            [ Label
                "Go to the police to inform them of Alejandro's disappearance"
                [SetActDeckCards 2 act2Deck1]
            , Label
                "Look for Alejandro on your own"
                [SetActDeckCards 2 act2Deck2]
            ]
        , SetAgendaDeck
        , SetActDeck
        , placeRivertown
        ]
          <> placeOtherLocations
          <> [MoveAllTo (toSource attrs) rivertownId]

      agendas <-
        genCards
          [ Agendas.threeFates
          , Agendas.behindTheCurtain
          , Agendas.hiddenEntanglements
          ]

      ThreadsOfFate
        <$> runMessage
          Setup
          ( attrs
              & (agendaStackL . at 1 ?~ agendas)
              & (actStackL . at 1 ?~ act1Deck)
              & (actStackL . at 3 ?~ act3Deck)
              & (setAsideCardsL .~ setAsideCards)
          )
    SetupStep target n | isTarget attrs target -> do
      gaveCustodyToHarlan <-
        getHasRecord
          TheInvestigatorsGaveCustodyOfTheRelicToHarlanEarnstone
      standalone <- getIsStandalone
      leadInvestigatorId <- getLeadInvestigatorId
      (msgs, nextStep) <- case n of
        4 ->
          pure
            ( Remember YouListenedToIchtacasTale
                : [AddToken Cultist | standalone]
            , 7
            )
        5 -> do
          pure
            ( [Remember IchtacaLeftWithoutYou]
            , if gaveCustodyToHarlan then 6 else 7
            )
        6 ->
          pure
            (
              [ chooseOne
                  leadInvestigatorId
                  [ Label
                      "“We should be wary of them.”"
                      ( if standalone
                          then [Record YouAreForgingYourOwnWay]
                          else
                            [ RemoveAllTokens Cultist
                            , RemoveAllTokens Tablet
                            , AddToken ElderThing
                            , Record YouAreForgingYourOwnWay
                            ]
                      )
                  , Label "“Maybe I should listen to them after all...”" []
                  ]
              ]
            , 7
            )
        _ -> error "Invalid step"
      pushAll $ msgs <> [SetupStep (toTarget attrs) nextStep]
      pure s
    PassedSkillTest iid _ _ (TokenTarget token) _ n -> do
      case tokenFace token of
        Cultist | isEasyStandard attrs && n < 1 -> do
          push $ InvestigatorAssignDamage iid (TokenSource token) DamageAny 1 0
        Cultist | isHardExpert attrs && n < 2 -> do
          push $ InvestigatorDirectDamage iid (TokenSource token) 1 0
        Tablet | isEasyStandard attrs && n < 1 -> do
          targets <-
            selectListMap EnemyTarget $
              NearestEnemyTo iid (EnemyWithTrait Trait.Cultist)
          unless (null targets) $ do
            push $
              chooseOrRunOne
                iid
                [TargetLabel target [PlaceDoom (TokenEffectSource Tablet) target 1] | target <- targets]
        Tablet | isHardExpert attrs && n < 2 -> do
          targets <-
            selectListMap EnemyTarget $
              NearestEnemyTo iid (EnemyWithTrait Trait.Cultist)
          pushAll [PlaceDoom (TokenEffectSource Tablet) target 1 | target <- targets]
        _ -> pure ()
      pure s
    FailedSkillTest iid _ _ (TokenTarget token) _ _ -> do
      case tokenFace token of
        Cultist | isEasyStandard attrs -> do
          push $ InvestigatorAssignDamage iid (TokenSource token) DamageAny 1 0
        Cultist | isHardExpert attrs -> do
          push $ InvestigatorDirectDamage iid (TokenSource token) 1 0
        Tablet | isEasyStandard attrs -> do
          targets <-
            selectListMap EnemyTarget $
              NearestEnemyTo iid (EnemyWithTrait Trait.Cultist)
          unless (null targets) $ do
            push $
              chooseOrRunOne
                iid
                [TargetLabel target [PlaceDoom (TokenEffectSource Tablet) target 1] | target <- targets]
        Tablet | isHardExpert attrs -> do
          targets <-
            selectListMap EnemyTarget $
              NearestEnemyTo iid (EnemyWithTrait Trait.Cultist)
          pushAll [PlaceDoom (TokenEffectSource Tablet) target 1 | target <- targets]
        ElderThing -> do
          push $ RemoveClues (TokenEffectSource ElderThing) (InvestigatorTarget iid) 1
        _ -> pure ()
      pure s
    ScenarioResolution _ -> do
      -- because we have multiple acts we might have an act that triggered the
      -- resolution and would not be counted so we need to determine that as
      -- well

      let
        actPairs = mapToList (scenarioActStack attrs)
        actPairCount = flip map actPairs $ \(n, acts) ->
          let
            c = flip count acts $ \actDef -> do
              ( (`elem` [Act.B, Act.D, Act.F])
                  . Act.actSide
                  . actSequence
                  . toAttrs
                )
                (Act.lookupAct (ActId $ toCardCode actDef) 0 nullCardId)
          in
            (n, c)
        actPairCountMap = IntMap.fromList actPairCount
        completedStack n =
          (== 3)
            . (+ findWithDefault 0 n actPairCountMap)
            . length
            . fromMaybe []
            $ lookup n (scenarioCompletedActStack attrs)

        act3bCompleted = completedStack 1
        act3dCompleted = completedStack 2
        act3fCompleted = completedStack 3
        act1sCompleted = length $ keys (scenarioCompletedActStack attrs)

      iids <- allInvestigatorIds
      leadInvestigatorId <- getLeadInvestigatorId
      gainXp <- toGainXp attrs $ getXpWithBonus act1sCompleted
      relicOwned <- getIsAlreadyOwned Assets.relicOfAgesADeviceOfSomeSort
      alejandroOwned <- getIsAlreadyOwned Assets.alejandroVela

      pushAll $
        [story iids resolution1]
          <> [ Record
                if act3bCompleted
                  then TheInvestigatorsFoundTheMissingRelic
                  else TheRelicIsMissing
             ]
          <> [ addCampaignCardToDeckChoice
              leadInvestigatorId
              iids
              Assets.relicOfAgesADeviceOfSomeSort
             | act3bCompleted && not relicOwned
             ]
          <> [ RemoveCampaignCard Assets.relicOfAgesADeviceOfSomeSort
             | not act3bCompleted
             ]
          <> [ Record
                if act3dCompleted
                  then TheInvestigatorsRescuedAlejandro
                  else AlejandroIsMissing
             ]
          <> [ addCampaignCardToDeckChoice
              leadInvestigatorId
              iids
              Assets.alejandroVela
             | act3dCompleted && not alejandroOwned
             ]
          <> [RemoveCampaignCard Assets.alejandroVela | not act3dCompleted]
          <> [ Record
                if act3fCompleted
                  then TheInvestigatorsForgedABondWithIchtaca
                  else IchtacaIsInTheDark
             ]
          <> [ addCampaignCardToDeckChoice
              leadInvestigatorId
              iids
              Assets.ichtacaTheForgottenGuardian
             | act3fCompleted
             ]
          <> [ chooseOne
                leadInvestigatorId
                [ Label
                    "Add Expedition Journal to your deck"
                    [ AddCampaignCardToDeck
                        leadInvestigatorId
                        Assets.expeditionJournal
                    ]
                , Label "Do not add Expedition Journal to your deck" []
                ]
             ]
          <> gainXp
          <> [EndOfGame Nothing]
      pure s
    _ -> ThreadsOfFate <$> runMessage msg attrs
