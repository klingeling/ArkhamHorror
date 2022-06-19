{-# LANGUAGE TemplateHaskell #-}
module Arkham.Classes.Entity.TH
  ( module X
  , module Arkham.Classes.Entity.TH
  ) where

import Arkham.Prelude

import Arkham.Classes.Entity as X
import Data.Char qualified as C
import Language.Haskell.TH.Syntax hiding ( Name )
import Language.Haskell.TH.Syntax qualified as TH

buildEntity :: String -> Q [Dec]
buildEntity nm = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  let conz = mapMaybe extractCon instances
  pure
    [ DataD
        []
        (TH.mkName nm)
        []
        Nothing
        conz
        [DerivClause (Just StockStrategy) (map ConT [''Show, ''Eq])]
    ]
 where
  extractCon (InstanceD _ _ (AppT _ con@(ConT name)) _) = Just $ NormalC
    (TH.mkName $ nameBase name ++ "'")
    [(Bang TH.NoSourceUnpackedness TH.NoSourceStrictness, con)]
  extractCon _ = Nothing

buildEntityLookupList :: String -> Q Exp
buildEntityLookupList nm = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  let conz = mapMaybe extractCon instances
  pure $ ListE conz
 where
  extractCon (InstanceD _ _ (AppT _ (ConT name)) _) = Just $ AppE
    (AppE (VarE $ TH.mkName "fmap") (ConE $ TH.mkName $ nameBase name ++ "'"))
    (VarE $ toFunName $ nameBase name)
  extractCon _ = Nothing
  toFunName [] = TH.mkName ""
  toFunName (x : xs) = TH.mkName $ C.toLower x : xs

entityRunMessage :: String -> Q Exp
entityRunMessage nm = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  a <- newName "a"
  msg <- newName "msg"
  x <- newName "x"
  let matches = mapMaybe (toMatch msg x) instances
  pure $ LamE [VarP msg, VarP a] $ CaseE (VarE a) matches
 where
  toMatch msg x (InstanceD _ _ (AppT _ (ConT name)) _) = Just $ Match
    (ConP (TH.mkName $ nameBase name <> "'") [VarP x])
    (NormalB $ AppE
      (AppE (VarE $ TH.mkName "fmap") (ConE $ TH.mkName $ nameBase name ++ "'"))
      (AppE (AppE (VarE $ TH.mkName "runMessage") (VarE msg)) (VarE x))
    )
    []
  toMatch _ _ _ = Nothing

entityF :: String -> String -> Q Exp
entityF nm fName = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  let f = TH.mkName fName
  a <- newName "a"
  x <- newName "x"
  let matches = mapMaybe (toMatch f x) instances
  pure $ LamE [VarP a] $ CaseE (VarE a) matches
 where
  toMatch f x (InstanceD _ _ (AppT _ (ConT name)) _) = Just $ Match
    (ConP (TH.mkName $ nameBase name <> "'") [VarP x])
    (NormalB $ AppE (VarE f) (VarE x))
    []
  toMatch _ _ _ = Nothing

entityF2 :: String -> String -> Q Exp
entityF2 nm fName = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  let f = TH.mkName fName
  a <- newName "a"
  p1 <- newName "p1"
  p2 <- newName "p2"
  x <- newName "x"
  let matches = mapMaybe (toMatch f p1 p2 x) instances
  pure $ LamE [VarP p1, VarP p2, VarP a] $ CaseE (VarE a) matches
 where
  toMatch f p1 p2 x (InstanceD _ _ (AppT _ (ConT name)) _) = Just $ Match
    (ConP (TH.mkName $ nameBase name <> "'") [VarP x])
    (NormalB $ AppE (AppE (AppE (VarE f) (VarE p1)) (VarE p2)) (VarE x))

    []
  toMatch _ _ _ _ _ = Nothing

entityF1 :: String -> String -> Q Exp
entityF1 nm fName = do
  ClassI _ instances <- reify (TH.mkName $ "Is" ++ nm)
  let f = TH.mkName fName
  a <- newName "a"
  p1 <- newName "p1"
  x <- newName "x"
  let matches = mapMaybe (toMatch f p1 x) instances
  pure $ LamE [VarP p1, VarP a] $ CaseE (VarE a) matches
 where
  toMatch f p1 x (InstanceD _ _ (AppT _ (ConT name)) _) = Just $ Match
    (ConP (TH.mkName $ nameBase name <> "'") [VarP x])
    (NormalB $ AppE (AppE (VarE f) (VarE p1)) (VarE x))
    []
  toMatch _ _ _ _ = Nothing
