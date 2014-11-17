{-# LANGUAGE OverloadedStrings #-}
-------------------------------------------
-- |
-- Module      : Web.Stripe.AppplicationFeeRefund
-- Copyright   : (c) David Johnson, 2014
-- Maintainer  : djohnson.m@gmail.com
-- Stability   : experimental
-- Portability : POSIX
--
-- < https:/\/\stripe.com/docs/api#fee_refunds >
--
-- @
-- import Web.Stripe
-- import Web.Stripe.ApplicationFee
--
-- main :: IO ()
-- main = do
--   let config = SecretKey "secret_key"
--   result <- stripe config $ getApplicationFeeRefund (FeeId "fee_id") (RefundId "refund_id")
--   case result of
--     Right applicationFeeRefund -> print applicationFeeRefund
--     Left stripeError           -> print stripeError
-- @
module Web.Stripe.ApplicationFeeRefund
    ( -- * API
      createApplicationFeeRefund
    , getApplicationFeeRefund
    , getApplicationFeeRefundExpandable
    , getApplicationFeeRefunds
    , getApplicationFeeRefundsExpandable
    , updateApplicationFeeRefund
      -- * Types
    , FeeId                  (..)
    , RefundId               (..)
    , ApplicationFee         (..)
    , ApplicationFeeRefund   (..)
    , StripeList             (..)
    , EndingBefore
    , StartingAfter
    , Limit
    , ExpandParams
    , MetaData
    , Amount
    ) where

import           Web.Stripe.Client.Types    (Method (POST, GET), StripeRequest (..),
                                             mkStripeRequest
                                            )
import           Web.Stripe.Client.Util     (getParams, toExpandable,
                                             toMetaData, toText, (</>))
import           Web.Stripe.Types           (Amount, ApplicationFee (..),
                                             ApplicationFeeRefund (..),
                                             EndingBefore, ExpandParams,
                                             FeeId (..), Limit, MetaData,
                                             RefundId (..), StartingAfter,
                                             StripeList (..))

------------------------------------------------------------------------------
-- | Create a new `ApplicationFeeRefund`
createApplicationFeeRefund
    :: FeeId        -- ^ The `FeeID` associated with the `ApplicationFee`
    -> Maybe Amount -- ^ The `Amount` associated with the `ApplicationFee` (optional)
    -> MetaData     -- ^ The `MetaData` associated with the `ApplicationFee` (optional)
    -> StripeRequest ApplicationFeeRefund
createApplicationFeeRefund
    (FeeId feeid)
    amount
    metadata    = request
  where request = mkStripeRequest POST url params
        url     = "application_fees" </> feeid </> "refunds"
        params  = toMetaData metadata ++ getParams [
                   ("amount", fmap toText amount)
                  ]

------------------------------------------------------------------------------
-- | Retrieve an existing 'ApplicationFeeRefund'
getApplicationFeeRefund
    :: FeeId     -- ^ The `FeeID` associated with the `ApplicationFee`
    -> RefundId  -- ^ The `ReufndId` associated with the `ApplicationFeeRefund`
    -> StripeRequest ApplicationFeeRefund
getApplicationFeeRefund feeid refundid =
  getApplicationFeeRefundExpandable feeid refundid []

------------------------------------------------------------------------------
-- | Retrieve an existing 'ApplicationFeeRefund'
getApplicationFeeRefundExpandable
    :: FeeId          -- ^ The `FeeID` associated with the `ApplicationFee`
    -> RefundId       -- ^ The `ReufndId` associated with the `ApplicationFeeRefund`
    -> ExpandParams   -- ^ The `ExpandParams` to be used for object expansion
    -> StripeRequest ApplicationFeeRefund
getApplicationFeeRefundExpandable (FeeId feeid) (RefundId refundid) expansion
    = request
  where request = mkStripeRequest GET url params
        url     = "application_fees" </> feeid </> "refunds" </> refundid
        params  = toExpandable expansion

------------------------------------------------------------------------------
-- | Retrieve a list of all 'ApplicationFeeRefund's for a given Application 'FeeId'
getApplicationFeeRefunds
    :: FeeId               -- ^ The `FeeID` associated with the application
    -> Limit               -- ^ `Limit` on how many `Refund`s to return (max 100, default 10)
    -> StartingAfter FeeId -- ^ Lower bound on how many `Refund`s to return
    -> EndingBefore FeeId  -- ^ Upper bound on how many `Refund`s to return
    -> StripeRequest (StripeList ApplicationFeeRefund)
getApplicationFeeRefunds
   feeid
   limit
   startingAfter
   endingBefore =
     getApplicationFeeRefundsExpandable
       feeid limit startingAfter endingBefore []

------------------------------------------------------------------------------
-- | Retrieve a list of all 'ApplicationFeeRefund's for a given Application 'FeeId'
getApplicationFeeRefundsExpandable
    :: FeeId               -- ^ The `FeeID` associated with the `ApplicationFee`
    -> Limit               -- ^ Limit on how many Refunds to return (max 100, default 10)
    -> StartingAfter FeeId -- ^ Lower bound on how many Refunds to return
    -> EndingBefore FeeId  -- ^ Upper bound on how many Refunds to return
    -> ExpandParams        -- ^ The `ExpandParams` to be used for object expansion
    -> StripeRequest (StripeList ApplicationFeeRefund)
getApplicationFeeRefundsExpandable
  (FeeId feeid)
   limit
   startingAfter
   endingBefore
   expandParams = request
  where
    request = mkStripeRequest GET url params
    url     = "application_fees" </> feeid </> "refunds"
    params  = getParams [
        ("limit", toText `fmap` limit )
      , ("starting_after", (\(FeeId x) -> x) `fmap` startingAfter)
      , ("ending_before", (\(FeeId x) -> x) `fmap` endingBefore)
      ] ++ toExpandable expandParams

------------------------------------------------------------------------------
-- | Update an `ApplicationFeeRefund` for a given Application `FeeId` and `RefundId`
updateApplicationFeeRefund
    :: FeeId    -- ^ The `FeeID` associated with the application
    -> RefundId -- ^ The `RefundId` associated with the application
    -> MetaData -- ^ The `MetaData` associated with the Fee (optional)
    -> StripeRequest (StripeList ApplicationFeeRefund)
updateApplicationFeeRefund
    (FeeId feeid)
    (RefundId refundid)
    metadata = request
  where
    request = mkStripeRequest GET url params
    url     = "application_fees" </> feeid </> "refunds" </> refundid
    params  = toMetaData metadata