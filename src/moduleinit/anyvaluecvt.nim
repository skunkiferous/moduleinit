# Copyright 2018 Sebastien Diot.

# Module anyvaluecvt

# This module provides converters from "simple types" to AnyValue.

import typetraits
import unicode

import moduleinit/anyvalue as av

converter toBoolAnyValue*(v: bool): AnyValue {.inline, noSideEffect.} =
  ## Converts a bool to a AnyValue.
  result.kind = avBool
  result.boolValue = v

converter toCharAnyValue*(v: char): AnyValue {.inline, noSideEffect.} =
  ## Converts a char to a AnyValue.
  result.kind = avChar
  result.charValue = v

converter toRuneAnyValue*(v: Rune): AnyValue {.inline, noSideEffect.} =
  ## Converts a Rune to a AnyValue.
  result.kind = avRune
  result.runeValue = v

converter toUintAnyValue*(v: uint): AnyValue {.inline, noSideEffect.} =
  ## Converts a uint to a AnyValue.
  result.kind = avUint
  result.uintValue = v

converter toUint8AnyValue*(v: uint8): AnyValue {.inline, noSideEffect.} =
  ## Converts a uint8 to a AnyValue.
  result.kind = avUint8
  result.uint8Value = v

converter toUint16AnyValue*(v: uint16): AnyValue {.inline, noSideEffect.} =
  ## Converts a uint16 to a AnyValue.
  result.kind = avUint16
  result.uint16Value = v

converter toUint32AnyValue*(v: uint32): AnyValue {.inline, noSideEffect.} =
  ## Converts a uint32 to a AnyValue.
  result.kind = avUint32
  result.uint32Value = v

converter toUint64AnyValue*(v: uint64): AnyValue {.inline, noSideEffect.} =
  ## Converts a uint64 to a AnyValue.
  result.kind = avUint64
  result.uint64Value = v

converter toIntAnyValue*(v: int): AnyValue {.inline, noSideEffect.} =
  ## Converts a int to a AnyValue.
  result.kind = avInt
  result.intValue = v

converter toInt8AnyValue*(v: int8): AnyValue {.inline, noSideEffect.} =
  ## Converts a int8 to a AnyValue.
  result.kind = avInt8
  result.int8Value = v

converter toInt16AnyValue*(v: int16): AnyValue {.inline, noSideEffect.} =
  ## Converts a int16 to a AnyValue.
  result.kind = avInt16
  result.int16Value = v

converter toInt32AnyValue*(v: int32): AnyValue {.inline, noSideEffect.} =
  ## Converts a int32 to a AnyValue.
  result.kind = avInt32
  result.int32Value = v

converter toInt64AnyValue*(v: int64): AnyValue {.inline, noSideEffect.} =
  ## Converts a int64 to a AnyValue.
  result.kind = avInt64
  result.int64Value = v

converter toFloat32AnyValue*(v: float32): AnyValue {.inline, noSideEffect.} =
  ## Converts a float32 to a AnyValue.
  result.kind = avFloat32
  result.float32Value = v

converter toFloat64AnyValue*(v: float64): AnyValue {.inline, noSideEffect.} =
  ## Converts a float64 to a AnyValue.
  result.kind = avFloat64
  result.float64Value = v

converter toCStringAnyValue*(v: cstring): AnyValue {.inline, noSideEffect.} =
  ## Converts a cstring to a AnyValue.
  result.kind = avCString
  result.cstringValue = v

converter toStringAnyValue*(v: string): AnyValue {.inline, noSideEffect.} =
  ## Converts a string to a AnyValue.
  result.kind = avString
  result.stringValue = v

converter toPointerAnyValue*(v: pointer): AnyValue {.inline, noSideEffect.} =
  ## Converts a pointer to a AnyValue.
  result.kind = avPointer
  result.pointerValue = v

converter toPtrAnyValue*[T](v: ptr T): AnyValue {.inline, noSideEffect.} =
  ## Converts a ptr T to a AnyValue.
  result.kind = avPtr
  result.ptrValue = cast[pointer](v)
  result.ptrType = T.name()

converter toRefAnyValue*[T: ref](v: T): AnyValue {.inline, noSideEffect.} =
  ## Converts a ref T to a AnyValue.
  result.kind = avRef
  result.refValue = v
  result.refType = T.name()

converter toBoolSeqAnyValue*(v: seq[bool]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[bool] to a AnyValue.
  result.kind = avBoolSeq
  result.boolSeqValue = v

converter toCharSeqAnyValue*(v: seq[char]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[char] to a AnyValue.
  result.kind = avCharSeq
  result.charSeqValue = v

converter toRuneSeqAnyValue*(v: seq[Rune]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[Rune] to a AnyValue.
  result.kind = avRuneSeq
  result.runeSeqValue = v

converter toUintSeqAnyValue*(v: seq[uint]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[uint] to a AnyValue.
  result.kind = avUintSeq
  result.uintSeqValue = v

converter toUint8SeqAnyValue*(v: seq[uint8]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[uint8] to a AnyValue.
  result.kind = avUint8Seq
  result.uint8SeqValue = v

converter toUint16SeqAnyValue*(v: seq[uint16]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[uint16] to a AnyValue.
  result.kind = avUint16Seq
  result.uint16SeqValue = v

converter toUint32SeqAnyValue*(v: seq[uint32]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[uint32] to a AnyValue.
  result.kind = avUint32Seq
  result.uint32SeqValue = v

converter toUint64SeqAnyValue*(v: seq[uint64]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[uint64] to a AnyValue.
  result.kind = avUint64Seq
  result.uint64SeqValue = v

converter toIntSeqAnyValue*(v: seq[int]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[int] to a AnyValue.
  result.kind = avIntSeq
  result.intSeqValue = v

converter toInt8SeqAnyValue*(v: seq[int8]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[int8] to a AnyValue.
  result.kind = avInt8Seq
  result.int8SeqValue = v

converter toInt16SeqAnyValue*(v: seq[int16]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[int16] to a AnyValue.
  result.kind = avInt16Seq
  result.int16SeqValue = v

converter toInt32SeqAnyValue*(v: seq[int32]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[int32] to a AnyValue.
  result.kind = avInt32Seq
  result.int32SeqValue = v

converter toInt64SeqAnyValue*(v: seq[int64]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[int64] to a AnyValue.
  result.kind = avInt64Seq
  result.int64SeqValue = v

converter toFloat32SeqAnyValue*(v: seq[float32]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[float32] to a AnyValue.
  result.kind = avFloat32Seq
  result.float32SeqValue = v

converter toFloat64SeqAnyValue*(v: seq[float64]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[float64] to a AnyValue.
  result.kind = avFloat64Seq
  result.float64SeqValue = v

converter toCStringSeqAnyValue*(v: seq[cstring]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[cstring] to a AnyValue.
  result.kind = avCStringSeq
  result.cstringSeqValue = v

converter toStringSeqAnyValue*(v: seq[string]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[string] to a AnyValue.
  result.kind = avStringSeq
  result.stringSeqValue = v

converter toPointerSeqAnyValue*(v: seq[pointer]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[pointer] to a AnyValue.
  result.kind = avPointerSeq
  result.pointerSeqValue = v

converter toPtrSeqAnyValue*[T](v: seq[ptr T]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[ptr T] to a AnyValue.
  result.kind = avPtrSeq
  result.ptrSeqValue = toPointerSeq(v)
  result.ptrSeqType = T.name()

converter toRefSeqAnyValue*[T: ref](v: seq[T]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[ref RootObj] to a AnyValue.
  result.kind = avRefSeq
  result.refSeqValue = toRefRootObjSeq(v)
  result.refSeqType = T.name()

converter toSeqAnyValueAnyValue*(v: seq[AnyValue]): AnyValue {.inline, noSideEffect.} =
  ## Converts a seq[AnyValue] to a AnyValue.
  result.kind = avAnySeq
  result.anyseqValue = v
