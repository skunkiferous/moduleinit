# Copyright 2018 Sebastien Diot.

# Module anyvalue

# This module allows, for example, a table to contain values of many different
# types. We do not support objects, but we support ref and ptr to them.
# Converters for AnyValue are in the module anyvaluecvt.

import typetraits
import unicode

type
  AnyValueType* = enum
    ## The list of types supported by AnyValue.
    ## Byte is an alias to uint8, and therefore not explicitly supported.
    ## Float is an alias to Float64, and therefore not explicitly supported.
    avString,
    avCString,
    avBool,
    avChar,
    avRune,
    avUint,
    avUint8,
    avUint16,
    avUint32,
    avUint64,
    avInt,
    avInt8,
    avInt16,
    avInt32,
    avInt64,
    avFloat32,
    avFloat64,
    avPointer,
    avPtr,
    avRef,
    avBoolSeq,
    avCharSeq,
    avRuneSeq,
    avUintSeq,
    avUint8Seq,
    avUint16Seq,
    avUint32Seq,
    avUint64Seq,
    avIntSeq,
    avInt8Seq,
    avInt16Seq,
    avInt32Seq,
    avInt64Seq,
    avFloat32Seq,
    avFloat64Seq,
    avCStringSeq,
    avStringSeq,
    avPointerSeq,
    avPtrSeq,
    avRefSeq,
    avAnySeq

  AnyValue* = object
    ## Can contain any sort of basic type.
    case kind*: AnyValueType
    of avString: stringValue*: string
    of avCString: cstringValue*: cstring
    of avBool: boolValue*: bool
    of avChar: charValue*: char
    of avRune: runeValue*: Rune
    of avUint: uintValue*: uint
    of avUint8: uint8Value*: uint8
    of avUint16: uint16Value*: uint16
    of avUint32: uint32Value*: uint32
    of avUint64: uint64Value*: uint64
    of avInt: intValue*: int
    of avInt8: int8Value*: int8
    of avInt16: int16Value*: int16
    of avInt32: int32Value*: int32
    of avInt64: int64Value*: int64
    of avFloat32: float32Value*: float32
    of avFloat64: float64Value*: float64
    of avPointer: pointerValue*: pointer
    of avPtr:
      ptrType*: cstring
      ptrValue*: pointer
    of avRef:
      refType*: cstring
      refValue*: ref RootObj
    of avBoolSeq: boolSeqValue*: seq[bool]
    of avCharSeq: charSeqValue*: seq[char]
    of avRuneSeq: runeSeqValue*: seq[Rune]
    of avUintSeq: uintSeqValue*: seq[uint]
    of avUint8Seq: uint8SeqValue*: seq[uint8]
    of avUint16Seq: uint16SeqValue*: seq[uint16]
    of avUint32Seq: uint32SeqValue*: seq[uint32]
    of avUint64Seq: uint64SeqValue*: seq[uint64]
    of avIntSeq: intSeqValue*: seq[int]
    of avInt8Seq: int8SeqValue*: seq[int8]
    of avInt16Seq: int16SeqValue*: seq[int16]
    of avInt32Seq: int32SeqValue*: seq[int32]
    of avInt64Seq: int64SeqValue*: seq[int64]
    of avFloat32Seq: float32SeqValue*: seq[float32]
    of avFloat64Seq: float64SeqValue*: seq[float64]
    of avCStringSeq: cstringSeqValue*: seq[cstring]
    of avStringSeq: stringSeqValue*: seq[string]
    of avPointerSeq: pointerSeqValue*: seq[pointer]
    of avPtrSeq:
      ptrSeqType*: cstring
      ptrSeqValue*: seq[pointer]
    of avRefSeq:
      refSeqType*: cstring
      refSeqValue*: seq[ref RootObj]
    of avAnySeq: anyseqValue*: seq[AnyValue]

proc isNil(v: var AnyValue): bool {.inline, noSideEffect.} = false
proc isNil(v: AnyValue): bool {.inline, noSideEffect.} = false

proc equals[A: AnyValue|var AnyValue|ref AnyValue|ptr AnyValue;
    B: AnyValue|var AnyValue|ref AnyValue|ptr AnyValue](a: A, b: B): bool {.noSideEffect.} =
  ## Compares AnyValue
  let bIsNil = b.isNil
  if a.isNil:
    return bIsNil
  if bIsNil or (a.kind != b.kind):
    return false
  # Neither is nil, and both are of the same kind...
  case a.kind:
    of avBool: return a.boolValue == b.boolValue
    of avChar: return a.charValue == b.charValue
    of avRune: return a.runeValue == b.runeValue
    of avUint: return a.uintValue == b.uintValue
    of avUint8: return a.uint8Value == b.uint8Value
    of avUint16: return a.uint16Value == b.uint16Value
    of avUint32: return a.uint32Value == b.uint32Value
    of avUint64: return a.uint64Value == b.uint64Value
    of avInt: return a.intValue == b.intValue
    of avInt8: return a.int8Value == b.int8Value
    of avInt16: return a.int16Value == b.int16Value
    of avInt32: return a.int32Value == b.int32Value
    of avInt64: return a.int64Value == b.int64Value
    of avFloat32: return a.float32Value == b.float32Value
    of avFloat64: return a.float64Value == b.float64Value
    of avCString: return a.cstringValue == b.cstringValue
    of avString: return a.stringValue == b.stringValue
    of avPointer: return a.pointerValue == b.pointerValue
    of avPtr: return (a.ptrType == b.ptrType) and (a.ptrValue == b.ptrValue)
    of avRef: return (a.refType == b.refType) and (a.refValue == b.refValue)
    of avBoolSeq: return a.boolSeqValue == b.boolSeqValue
    of avCharSeq: return a.charSeqValue == b.charSeqValue
    of avRuneSeq: return a.runeSeqValue == b.runeSeqValue
    of avUintSeq: return a.uintSeqValue == b.uintSeqValue
    of avUint8Seq: return a.uint8SeqValue == b.uint8SeqValue
    of avUint16Seq: return a.uint16SeqValue == b.uint16SeqValue
    of avUint32Seq: return a.uint32SeqValue == b.uint32SeqValue
    of avUint64Seq: return a.uint64SeqValue == b.uint64SeqValue
    of avIntSeq: return a.intSeqValue == b.intSeqValue
    of avInt8Seq: return a.int8SeqValue == b.int8SeqValue
    of avInt16Seq: return a.int16SeqValue == b.int16SeqValue
    of avInt32Seq: return a.int32SeqValue == b.int32SeqValue
    of avInt64Seq: return a.int64SeqValue == b.int64SeqValue
    of avFloat32Seq: return a.float32SeqValue == b.float32SeqValue
    of avFloat64Seq: return a.float64SeqValue == b.float64SeqValue
    of avCStringSeq: return a.cstringSeqValue == b.cstringSeqValue
    of avStringSeq: return a.stringSeqValue == b.stringSeqValue
    of avPointerSeq: return a.pointerSeqValue == b.pointerSeqValue
    of avPtrSeq: return (a.ptrSeqType == b.ptrSeqType) and (a.ptrSeqValue == b.ptrSeqValue)
    of avRefSeq: return (a.refSeqType == b.refSeqType) and (a.refSeqValue == b.refSeqValue)
    of avAnySeq: return a.anyseqValue == b.anyseqValue

proc `==`*(a: AnyValue, b: AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: AnyValue, b: var AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: AnyValue, b: ptr AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: AnyValue, b: ref AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: var AnyValue, b: AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: var AnyValue, b: var AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: var AnyValue, b: ptr AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: var AnyValue, b: ref AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ptr AnyValue, b: AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ptr AnyValue, b: var AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ptr AnyValue, b: ptr AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ptr AnyValue, b: ref AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ref AnyValue, b: AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ref AnyValue, b: var AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ref AnyValue, b: ptr AnyValue): bool {.inline,noSideEffect.} = equals(a, b)
proc `==`*(a: ref AnyValue, b: ref AnyValue): bool {.inline,noSideEffect.} = equals(a, b)

proc `$`(p: pointer): string {.inline.} = repr(p)
proc `$`(r: ref RootObj): string {.inline.} = repr(r)

proc toString[A: AnyValue|var AnyValue|ref AnyValue|ptr AnyValue](a: A): string =
  ## Stringify AnyValue
  if a.isNil:
    return "nil"
  case a.kind:
    of avBool: return $a.boolValue
    of avChar: return $a.charValue
    of avRune: return $a.runeValue
    of avUint: return $a.uintValue
    of avUint8: return $a.uint8Value
    of avUint16: return $a.uint16Value
    of avUint32: return $a.uint32Value
    of avUint64: return $a.uint64Value
    of avInt: return $a.intValue
    of avInt8: return $a.int8Value
    of avInt16: return $a.int16Value
    of avInt32: return $a.int32Value
    of avInt64: return $a.int64Value
    of avFloat32: return $a.float32Value
    of avFloat64: return $a.float64Value
    of avCString: return $a.cstringValue
    of avString: return a.stringValue
    of avPointer: return $a.pointerValue
    of avPtr: return $a.ptrType & ":" & $a.ptrValue
    of avRef: return $a.refType & ":" & $a.refValue
    of avBoolSeq: return $a.boolSeqValue
    of avCharSeq: return $a.charSeqValue
    of avRuneSeq: return $a.runeSeqValue
    of avUintSeq: return $a.uintSeqValue
    of avUint8Seq: return $a.uint8SeqValue
    of avUint16Seq: return $a.uint16SeqValue
    of avUint32Seq: return $a.uint32SeqValue
    of avUint64Seq: return $a.uint64SeqValue
    of avIntSeq: return $a.intSeqValue
    of avInt8Seq: return $a.int8SeqValue
    of avInt16Seq: return $a.int16SeqValue
    of avInt32Seq: return $a.int32SeqValue
    of avInt64Seq: return $a.int64SeqValue
    of avFloat32Seq: return $a.float32SeqValue
    of avFloat64Seq: return $a.float64SeqValue
    of avCStringSeq: return $a.cstringSeqValue
    of avStringSeq: return $a.stringSeqValue
    of avPointerSeq: return $a.pointerSeqValue
    of avPtrSeq: return $a.ptrSeqType & ":" & $a.ptrSeqValue
    of avRefSeq: return $a.refSeqType & ":" & $a.refSeqValue
    of avAnySeq: return $a.anyseqValue

proc `$`*(a: AnyValue): string {.inline.} = toString(a)
proc `$`*(a: var AnyValue): string {.inline.} = toString(a)
proc `$`*(a: ref AnyValue): string {.inline.} = toString(a)
proc `$`*(a: ptr AnyValue): string {.inline.} = toString(a)

proc toPointerSeq*[T](v: seq[ptr T]): seq[pointer] {.inline, noSideEffect.} =
  ## Converts a seq[ptr T] to  a seq[pointer]
  result = nil
  if not v.isNil:
    result = newSeq[pointer](len(v))
    for i,r in v:
      result[i] = r

proc toRefRootObjSeq*[T: ref](v: seq[T]): seq[ref RootObj] {.inline, noSideEffect.} =
  ## Converts a seq[ref T] to  a seq[ref RootObj]
  result = nil
  if not v.isNil:
    result = newSeq[ref RootObj](len(v))
    for i,r in v:
      result[i] = r
