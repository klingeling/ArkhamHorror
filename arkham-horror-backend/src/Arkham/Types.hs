{-# LANGUAGE DerivingStrategies         #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
module Arkham.Types where

import           Data.Aeson       (withObject)
import           Data.Aeson.Types (ToJSONKey)
import           Import

newtype Scenario = Scenario { getScenario :: Text }
  deriving newtype (ToJSON)

newtype Cycle = Cycle { getCycle :: Text }
  deriving newtype (Eq, Ord, ToJSON, ToJSONKey)

data GameSettings = GameSettings
  { cycleId :: ArkhamHorrorCycleId
  , scenarioId :: ArkhamHorrorScenarioId
  }
  deriving stock (Generic)
  deriving anyclass (ToJSON)

instance FromJSON GameSettings where
  parseJSON = withObject "GameSettings" $ \v -> GameSettings
    <$> v .: "cycleId"
    <*> v .: "scenarioId"

instance FromJSON Cycle where
  parseJSON = withObject "Cycle" $ \v -> Cycle
    <$> v .: "name"

instance FromJSON Scenario where
  parseJSON = withObject "Scenario" $ \v -> Scenario
    <$> v .: "name"
