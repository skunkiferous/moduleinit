# Copyright 2018 Sebastien Diot.

import typetraits
import unicode

import moduleinit/anyvalue as av
import moduleinit/anyvaluecvt

type
  Dummy = ref object of RootObj

var d: Dummy

let boolValue: bool = true
let charValue: char = char(42)
let runeValue: Rune = Rune(42)
let uintValue: uint = 42
let uint8Value: uint8 = 42'u8
let uint16Value: uint16 = 42'u16
let uint32Value: uint32 = 42'u32
let uint64Value: uint64 = 42'u64
let intValue: int = 42
let int8Value: int8 = 42'i8
let int16Value: int16 = 42'i16
let int32Value: int32 = 42'i32
let int64Value: int64 = 42'i64
let float32Value: float32 = 42.0'f32
let float64Value: float64 = 42.0'f64
let stringValue: string = "42"
let cstringValue: cstring = stringValue.cstring
let pointerValue: pointer = cast[pointer](cstringValue)
let ptrValue: ptr Dummy = addr d
let refValue: Dummy = nil
let boolSeqValue: seq[bool] = @[boolValue]
let charSeqValue: seq[char] = @[charValue]
let runeSeqValue: seq[Rune] = @[runeValue]
let uintSeqValue: seq[uint] = @[uintValue]
let uint8SeqValue: seq[uint8] = @[uint8Value]
let uint16SeqValue: seq[uint16] = @[uint16Value]
let uint32SeqValue: seq[uint32] = @[uint32Value]
let uint64SeqValue: seq[uint64] = @[uint64Value]
let intSeqValue: seq[int] = @[intValue]
let int8SeqValue: seq[int8] = @[int8Value]
let int16SeqValue: seq[int16] = @[int16Value]
let int32SeqValue: seq[int32] = @[int32Value]
let int64SeqValue: seq[int64] = @[int64Value]
let float32SeqValue: seq[float32] = @[float32Value]
let float64SeqValue: seq[float64] = @[float64Value]
let cstringSeqValue: seq[cstring] = @[cstringValue]
let stringSeqValue: seq[string] = @[stringValue]
let pointerSeqValue: seq[pointer] = @[pointerValue]
let ptrSeqValue: seq[ptr Dummy] = @[ptrValue]
let refSeqValue: seq[Dummy] = @[refValue]

var anyValue: AnyValue
anyValue.kind = avInt
anyValue.intValue = 42

let anyseqValue: seq[AnyValue] = @[anyValue]

let boolValueAV: AnyValue = boolValue
let charValueAV: AnyValue = charValue
let runeValueAV: AnyValue = runeValue
let uintValueAV: AnyValue = uintValue
let uint8ValueAV: AnyValue = uint8Value
let uint16ValueAV: AnyValue = uint16Value
let uint32ValueAV: AnyValue = uint32Value
let uint64ValueAV: AnyValue = uint64Value
let intValueAV: AnyValue = intValue
let int8ValueAV: AnyValue = int8Value
let int16ValueAV: AnyValue = int16Value
let int32ValueAV: AnyValue = int32Value
let int64ValueAV: AnyValue = int64Value
let float32ValueAV: AnyValue = float32Value
let float64ValueAV: AnyValue = float64Value
let stringValueAV: AnyValue = stringValue
let cstringValueAV: AnyValue = cstringValue
let pointerValueAV: AnyValue = pointerValue
let ptrValueAV: AnyValue = ptrValue
let refValueAV: AnyValue = refValue
let boolSeqValueAV: AnyValue = boolSeqValue
let charSeqValueAV: AnyValue = charSeqValue
let runeSeqValueAV: AnyValue = runeSeqValue
let uintSeqValueAV: AnyValue = uintSeqValue
let uint8SeqValueAV: AnyValue = uint8SeqValue
let uint16SeqValueAV: AnyValue = uint16SeqValue
let uint32SeqValueAV: AnyValue = uint32SeqValue
let uint64SeqValueAV: AnyValue = uint64SeqValue
let intSeqValueAV: AnyValue = intSeqValue
let int8SeqValueAV: AnyValue = int8SeqValue
let int16SeqValueAV: AnyValue = int16SeqValue
let int32SeqValueAV: AnyValue = int32SeqValue
let int64SeqValueAV: AnyValue = int64SeqValue
let float32SeqValueAV: AnyValue = float32SeqValue
let float64SeqValueAV: AnyValue = float64SeqValue
let cstringSeqValueAV: AnyValue = cstringSeqValue
let stringSeqValueAV: AnyValue = stringSeqValue
let pointerSeqValueAV: AnyValue = pointerSeqValue
let ptrSeqValueAV: AnyValue = ptrSeqValue
let refSeqValueAV: AnyValue = refSeqValue
let anyseqValueAV: AnyValue = anyseqValue

assert(boolValueAV.boolValue == boolValue)
assert(charValueAV.charValue == charValue)
assert(runeValueAV.runeValue == runeValue)
assert(uintValueAV.uintValue == uintValue)
assert(uint8ValueAV.uint8Value == uint8Value)
assert(uint16ValueAV.uint16Value == uint16Value)
assert(uint32ValueAV.uint32Value == uint32Value)
assert(uint64ValueAV.uint64Value == uint64Value)
assert(intValueAV.intValue == intValue)
assert(int8ValueAV.int8Value == int8Value)
assert(int16ValueAV.int16Value == int16Value)
assert(int32ValueAV.int32Value == int32Value)
assert(int64ValueAV.int64Value == int64Value)
assert(float32ValueAV.float32Value == float32Value)
assert(float64ValueAV.float64Value == float64Value)
assert(stringValueAV.stringValue == stringValue)
assert(cstringValueAV.cstringValue == cstringValue)
assert(pointerValueAV.pointerValue == pointerValue)
assert(ptrValueAV.ptrValue == ptrValue)
assert(ptrValueAV.ptrType == Dummy.name())
assert(refValueAV.refValue == refValue)
assert(refValueAV.refType == Dummy.name())
assert(boolSeqValueAV.boolSeqValue == boolSeqValue)
assert(charSeqValueAV.charSeqValue == charSeqValue)
assert(runeSeqValueAV.runeSeqValue == runeSeqValue)
assert(uintSeqValueAV.uintSeqValue == uintSeqValue)
assert(uint8SeqValueAV.uint8SeqValue == uint8SeqValue)
assert(uint16SeqValueAV.uint16SeqValue == uint16SeqValue)
assert(uint32SeqValueAV.uint32SeqValue == uint32SeqValue)
assert(uint64SeqValueAV.uint64SeqValue == uint64SeqValue)
assert(intSeqValueAV.intSeqValue == intSeqValue)
assert(int8SeqValueAV.int8SeqValue == int8SeqValue)
assert(int16SeqValueAV.int16SeqValue == int16SeqValue)
assert(int32SeqValueAV.int32SeqValue == int32SeqValue)
assert(int64SeqValueAV.int64SeqValue == int64SeqValue)
assert(float32SeqValueAV.float32SeqValue == float32SeqValue)
assert(float64SeqValueAV.float64SeqValue == float64SeqValue)
assert(cstringSeqValueAV.cstringSeqValue == cstringSeqValue)
assert(stringSeqValueAV.stringSeqValue == stringSeqValue)
assert(pointerSeqValueAV.pointerSeqValue == pointerSeqValue)
assert(ptrSeqValueAV.ptrSeqValue == toPointerSeq(ptrSeqValue))
assert(ptrSeqValueAV.ptrSeqType == Dummy.name())
assert(refSeqValueAV.refSeqValue == toRefRootObjSeq(refSeqValue))
assert(refSeqValueAV.refSeqType == Dummy.name())
assert(anyseqValueAV.anyseqValue == anyseqValue)
echo("anyvalue tested")
