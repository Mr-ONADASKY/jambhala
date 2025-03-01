module Jambhala.Utils
  ( ContractExports,
    ContractM,
    ExportTemplate (..),
    JambExports,
    JambContracts,
    DataExport (..),
    EmulatorTest,
    MintingContract,
    MintingEndpoint (..),
    Transaction (..),
    ValidatorContract,
    ValidatorEndpoints (..),
    andUtxos,
    defExports,
    defaultSlotBeginTime,
    defaultSlotEndTime,
    export,
    forWallet,
    fromWallet,
    getContractAddress,
    getCurrencySymbol,
    getCurrentInterval,
    getUtxosAt,
    getDatumInDatumFromQuery,
    getDecoratedTxOutDatum,
    getOwnPkh,
    initEmulator,
    logStr,
    submitAndConfirm,
    mkDatum,
    mkMintingContract,
    mkMintingValue,
    mkRedeemer,
    mkUntypedMintingPolicy,
    mkUntypedValidator,
    mkValidatorContract,
    mustAllBeSpentWith,
    mustSign,
    mustBeSpentWith,
    mustMint,
    mustPayToScriptWithDatum,
    pkhForWallet,
    scriptLookupsFor,
    toJSONfile,
    toWallet,
    wait,
    waitUntil,
  )
where

import Jambhala.CLI.Emulator
  ( andUtxos,
    defaultSlotBeginTime,
    defaultSlotEndTime,
    forWallet,
    fromWallet,
    getContractAddress,
    getCurrencySymbol,
    getCurrentInterval,
    getDatumInDatumFromQuery,
    getDecoratedTxOutDatum,
    getOwnPkh,
    getUtxosAt,
    initEmulator,
    logStr,
    mkDatum,
    mkMintingValue,
    mkRedeemer,
    mustAllBeSpentWith,
    mustBeSpentWith,
    mustMint,
    mustPayToScriptWithDatum,
    mustSign,
    pkhForWallet,
    submitAndConfirm,
    toWallet,
    wait,
    waitUntil,
  )
import Jambhala.CLI.Export (ExportTemplate (..), JambExports, defExports, export, toJSONfile)
import Jambhala.CLI.Types
import Jambhala.Plutus

-- Make Jambhala-compatible contracts

-- | Converts a validator's compiled UPLC code into a Jambhala `ValidatorContract` value.
mkValidatorContract ::
  CompiledCode (BuiltinData -> BuiltinData -> BuiltinData -> ()) ->
  ValidatorContract contract
mkValidatorContract = ValidatorContract . mkValidatorScript

-- | Converts a minting policy's compiled UPLC code into a Jambhala `MintingContract` value.
mkMintingContract ::
  CompiledCode (BuiltinData -> BuiltinData -> ()) ->
  MintingContract contract
mkMintingContract = MintingContract . mkMintingPolicyScript

{-# INLINEABLE mkUntypedValidator #-}

-- | A more efficient implementation of the `mkUntypedValidator` method of the `IsScriptContext` typeclass
mkUntypedValidator ::
  ( UnsafeFromData a,
    UnsafeFromData b
  ) =>
  (a -> b -> ScriptContext -> Bool) ->
  (BuiltinData -> BuiltinData -> BuiltinData -> ())
mkUntypedValidator f a b ctx =
  check $
    f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData b)
      (unsafeFromBuiltinData ctx)

{-# INLINEABLE mkUntypedMintingPolicy #-}

-- | A more efficient implementation of the `mkUntypedMintingPolicy` method of the `IsScriptContext` typeclass
mkUntypedMintingPolicy ::
  UnsafeFromData a =>
  (a -> ScriptContext -> Bool) ->
  (BuiltinData -> BuiltinData -> ())
mkUntypedMintingPolicy f a ctx =
  check $
    f
      (unsafeFromBuiltinData a)
      (unsafeFromBuiltinData ctx)