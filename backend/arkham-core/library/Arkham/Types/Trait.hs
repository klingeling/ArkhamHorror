module Arkham.Types.Trait
  ( Trait(..)
  )
where

import ClassyPrelude
import Data.Aeson

data Trait
  = Agency
  | Ally
  | AncientOne
  | Arkham
  | Armor
  | Artist
  | Assistant
  | Augury
  | Avatar
  | Bayou
  | Believer
  | Blessed
  | Blunder
  | Bold
  | Boon
  | Byakhee
  | Cave
  | Central
  | Charm
  | Chosen
  | Civic
  | Clairvoyant
  | Clothing
  | Composure
  | Condition
  | Connection
  | Conspirator
  | Creature
  | Criminal
  | Cultist
  | Curse
  | Cursed
  | DarkYoung
  | DeepOne
  | Desperate
  | Detective
  | Developed
  | Dreamer
  | Dreamlands
  | Drifter
  | Elite
  | Endtimes
  | Evidence
  | Expert
  | Extradimensional
  | Fated
  | Favor
  | Firearm
  | Flaw
  | Footwear
  | Fortune
  | Gambit
  | Geist
  | Ghoul
  | Grant
  | Hazard
  | Hex
  | Humanoid
  | Hunter
  | Illicit
  | Improvised
  | Injury
  | Innate
  | Insight
  | Instrument
  | Item
  | Job
  | Lunatic
  | Madness
  | Medic
  | Melee
  | Miskatonic
  | Monster
  | Mystery
  | NewOrleans
  | Nightgaunt
  | Obstacle
  | Occult
  | Omen
  | Pact
  | Paradox
  | Patron
  | Performer
  | Police
  | Practiced
  | Ranged
  | Relic
  | Reporter
  | Research
  | Ritual
  | Riverside
  | Scholar
  | Science
  | Serpent
  | Service
  | SilverTwilight
  | Socialite
  | Song
  | Sorcerer
  | Spell
  | Spirit
  | Summon
  | Supply
  | Syndicate
  | Tactic
  | Talent
  | Tarot
  | Task
  | Terror
  | Tindalos
  | Tome
  | Tool
  | Trap
  | Trick
  | Upgrade
  | Veteran
  | Warden
  | Wayfarer
  | Weapon
  | Wilderness
  | Witch
  | Woods
  | Unhallowed
  | Yithian
  deriving stock (Show, Eq, Generic)
  deriving anyclass (ToJSON, FromJSON, Hashable)
