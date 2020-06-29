module Arkham.Types.Scenario
  ( ArkhamScenarioCode(..)
  , ArkhamScenario(..)
  )
where

import ClassyPrelude
import Data.Aeson
import Data.Aeson.Casing

newtype ArkhamScenarioCode = ArkhamScenarioCode { unArkhamScenarioCode :: Text }
  deriving newtype (Eq, Show, ToJSON, FromJSON, Hashable)

data ArkhamScenario = ArkhamScenario
  { asScenarioCode :: ArkhamScenarioCode
  , asName :: Text
  , asGuide :: Text
  }
  deriving stock (Generic, Show)

instance ToJSON ArkhamScenario where
  toJSON =
    genericToJSON $ defaultOptions { fieldLabelModifier = camelCase . drop 2 }
  toEncoding = genericToEncoding
    $ defaultOptions { fieldLabelModifier = camelCase . drop 2 }

instance FromJSON ArkhamScenario where
  parseJSON = genericParseJSON
    $ defaultOptions { fieldLabelModifier = camelCase . drop 2 }
