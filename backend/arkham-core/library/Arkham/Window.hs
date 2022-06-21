module Arkham.Window where

import Arkham.Prelude

import Arkham.Attack
import Arkham.Action (Action)
import Arkham.Agenda.AdvancementReason (AgendaAdvancementReason)
import Arkham.SkillTest.Base
import Arkham.SkillType (SkillType)
import Arkham.Card (Card)
import Arkham.DamageEffect (DamageEffect)
import Arkham.Deck
import Arkham.DefeatedBy
import Arkham.Id
import Arkham.Matcher (LocationMatcher)
import Arkham.Phase (Phase)
import Arkham.Source (Source)
import Arkham.Target (Target)
import Arkham.Timing (Timing)
import Arkham.Token (Token)

data Window = Window
  { windowTiming :: Timing
  , windowType :: WindowType
  }
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)

data WindowType
  = ActAdvance ActId
  | AddedToVictory Card
  | AgendaAdvance AgendaId
  | AgendaWouldAdvance AgendaAdvancementReason AgendaId
  | AllDrawEncounterCard
  | AllUndefeatedInvestigatorsResigned
  | AmongSearchedCards InvestigatorId
  | AnyPhaseBegins
  | AssetDefeated AssetId
  | AssignedHorror Source InvestigatorId [Target]
  | AtEndOfRound
  | ChosenRandomLocation LocationId
  | CommittedCard InvestigatorId Card
  | CommittedCards InvestigatorId [Card]
  | DealtDamage Source DamageEffect Target
  | DealtHorror Source Target
  | DeckHasNoCards InvestigatorId
  | Defeated Source
  | Discarded InvestigatorId Card
  | DiscoverClues InvestigatorId LocationId Int
  | DiscoveringLastClue InvestigatorId LocationId
  | DrawCard InvestigatorId Card DeckSignifier
  | DrawToken InvestigatorId Token
  | DrawingStartingHand InvestigatorId
  | DuringTurn InvestigatorId
  | EndOfGame
  | EndTurn InvestigatorId
  | EnemyAttacked InvestigatorId Source EnemyId
  | EnemyAttacks InvestigatorId EnemyId EnemyAttackType
  | EnemyAttemptsToSpawnAt EnemyId LocationMatcher
  | EnemyDefeated InvestigatorId EnemyId
  | EnemyEngaged InvestigatorId EnemyId
  | EnemyEnters EnemyId LocationId
  | EnemyEvaded InvestigatorId EnemyId
  | EnemyLeaves EnemyId LocationId
  | EnemySpawns EnemyId LocationId
  | EnemyWouldAttack InvestigatorId EnemyId EnemyAttackType
  | EnemyWouldBeDefeated EnemyId
  | EnterPlay Target
  | Entering InvestigatorId LocationId
  | FailAttackEnemy InvestigatorId EnemyId Int
  | FailEvadeEnemy InvestigatorId EnemyId Int
  | FailInvestigationSkillTest InvestigatorId LocationId Int
  | FailSkillTest InvestigatorId Int
  | FailSkillTestAtOrLess InvestigatorId Int
  | FastPlayerWindow
  | GainsClues InvestigatorId Int
  | InDiscardWindow InvestigatorId Window
  | InHandWindow InvestigatorId Window
  | InitiatedSkillTest InvestigatorId (Maybe Action) Int
  | InvestigatorDefeated Source DefeatedBy InvestigatorId
  | InvestigatorEliminated InvestigatorId
  | LastClueRemovedFromAsset AssetId
  | LeavePlay Target
  | Leaving InvestigatorId LocationId
  | MoveAction InvestigatorId LocationId LocationId
  | MovedButBeforeEnemyEngagement InvestigatorId LocationId
  | MovedBy Source LocationId InvestigatorId
  | MovedFromHunter EnemyId
  | Moves InvestigatorId LocationId LocationId
  | NonFast
  | PassInvestigationSkillTest InvestigatorId LocationId Int
  | PassSkillTest (Maybe Action) Source InvestigatorId Int
  | PerformAction InvestigatorId Action
  | PhaseBegins Phase
  | PhaseEnds Phase
  | PlaceUnderneath Target Card
  | PlacedClues Target Int
  | PlacedDamage InvestigatorId Int
  | PlacedHorror InvestigatorId Int
  | PlacedDoom Target Int
  | PlayCard InvestigatorId Card
  | PutLocationIntoPlay InvestigatorId LocationId
  | RevealLocation InvestigatorId LocationId
  | RevealToken InvestigatorId Token
  | RevealTokenWithNegativeModifier InvestigatorId Token
  | SkillTest SkillType
  | SkillTestEnded SkillTest
  | SuccessfulAttackEnemy InvestigatorId EnemyId Int
  | SuccessfulEvadeEnemy InvestigatorId EnemyId Int
  | SuccessfulInvestigation InvestigatorId LocationId
  | TakeDamage Source DamageEffect Target
  | TookControlOfAsset InvestigatorId AssetId
  | TurnBegins InvestigatorId
  | TurnEnds InvestigatorId
  | WouldBeDiscarded Target
  | WouldDrawEncounterCard InvestigatorId Phase
  | WouldFailSkillTest InvestigatorId
  | WouldPassSkillTest InvestigatorId
  | WouldReady Target
  | WouldRevealChaosToken Source InvestigatorId
  | WouldTakeDamage Source Target
  | WouldTakeDamageOrHorror Source Target Int Int
  | WouldTakeHorror Source Target
  deriving stock (Show, Generic, Eq)
  deriving anyclass (ToJSON, FromJSON, Hashable)
