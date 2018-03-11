# Copyright 2018 Sebastien Diot.

# Module: stringvalue

## This module can be used to pass small "strings" across threads, or store
## them globally, without having to worry about the local GC (as Nim strings
## are local GCed objects). The "strings" are meant to be used as "values",
## rather than "reference objects", but can also be allocated on the shared
## heap.

import hashes

export hash, `==`

proc c_strcmp(a, b: cstring): cint {.
  importc: "strcmp", header: "<string.h>", noSideEffect.}

proc c_strlen(a: cstring): cint {.
  importc: "strlen", header: "<string.h>", noSideEffect.}

type
  StringValue*[LEN_PLUS_ONE: static[int]] = distinct array[LEN_PLUS_ONE,char]
    ## Represents a "string value" (as with strings and strings, len(s) is
    ## excluding the terminating '\0').

proc cstr*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE]): cstring {.inline, noSideEffect.} =
  ## Returns the 'raw' cstring of the var StringValue
  result = cast[cstring](addr sv)

proc cstr*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE]): cstring {.inline, noSideEffect.} =
  ## Returns the 'raw' cstring of the ptr StringValue
  result = cast[cstring](sv)

template unsafeCstr*[LEN_PLUS_ONE](sv: StringValue[LEN_PLUS_ONE]): cstring =
  ## Returns the 'raw' cstring of the StringValue
  cast[cstring](unsafeAddr sv)

proc `[]`*[LEN_PLUS_ONE: static[int],I: Ordinal](sv: var StringValue[LEN_PLUS_ONE]; i: I): char {.inline, noSideEffect.} =
  ## Returns a char of the StringValue
  cast[cstring](addr sv)[i]

proc `[]`*[LEN_PLUS_ONE: static[int],I: Ordinal](sv: StringValue[LEN_PLUS_ONE]; i: I): char {.inline, noSideEffect.} =
  ## Returns a char of the StringValue
  cast[cstring](unsafeAddr sv)[i]

proc `[]`*[LEN_PLUS_ONE: static[int],I: Ordinal](sv: ptr StringValue[LEN_PLUS_ONE]; i: I): char {.inline, noSideEffect.} =
  ## Returns a char of the StringValue
  cast[cstring](sv)[i]

proc `[]=`*[LEN_PLUS_ONE: static[int],I: Ordinal](sv: var StringValue[LEN_PLUS_ONE]; i: I; c: char) {.inline, noSideEffect.} =
  ## Returns a char of the StringValue
  cast[ptr char](cast[ByteAddress](addr sv) +% i * sizeof(char))[] = c

proc `[]=`*[LEN_PLUS_ONE: static[int],I: Ordinal](sv: ptr StringValue[LEN_PLUS_ONE]; i: I; c: char) {.inline, noSideEffect.} =
  ## Returns a char of the StringValue
  cast[ptr char](cast[ByteAddress](sv) +% i * sizeof(char))[] = c

proc len*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE]): int {.inline, noSideEffect.} =
  ## Returns the len of the StringValue
  int(c_strlen(cast[cstring](addr sv)))

proc len*[LEN_PLUS_ONE: static[int]](sv: StringValue[LEN_PLUS_ONE]): int {.inline, noSideEffect.} =
  ## Returns the len of the StringValue
  int(c_strlen(cast[cstring](unsafeAddr sv)))

proc len*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE]): int {.inline, noSideEffect.} =
  ## Returns the len of the StringValue
  int(c_strlen(cast[cstring](sv)))

proc `$`*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE]): string {.inline.} =
  ## Returns the string representation of the StringValue
  result = $cast[cstring](addr sv)

proc `$`*[LEN_PLUS_ONE: static[int]](sv: StringValue[LEN_PLUS_ONE]): string {.inline.} =
  ## Returns the string representation of the StringValue
  result = $cast[cstring](unsafeAddr sv)

proc `$`*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE]): string {.inline.} =
  ## Returns the string representation of the StringValue
  result = $cast[cstring](sv)

proc hash*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE]): Hash {.inline, noSideEffect.} =
  ## Returns the hash of the StringValue
  result = hash(cast[cstring](addr sv))

proc hash*[LEN_PLUS_ONE: static[int]](sv: StringValue[LEN_PLUS_ONE]): Hash {.inline, noSideEffect.} =
  ## Returns the hash of the StringValue
  result = hash(cast[cstring](unsafeAddr sv))

proc hash*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE]): Hash {.inline, noSideEffect.} =
  ## Returns the hash of the StringValue
  result = hash(cast[cstring](sv))

proc `==`*[LEN_PLUS_ONE: static[int]](a, b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](addr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](unsafeAddr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](addr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a, b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](unsafeAddr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE], cs: cstring): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](addr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: StringValue[LEN_PLUS_ONE], cs: cstring): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](unsafeAddr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](cs: cstring, sv: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](addr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](cs: cstring, sv: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](unsafeAddr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: var StringValue[LEN_PLUS_ONE], s: string): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](addr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: StringValue[LEN_PLUS_ONE], s: string): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](unsafeAddr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](s: string, sv: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](addr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](s: string, sv: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](unsafeAddr sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a, b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](unsafeAddr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE], cs: cstring): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](cs: cstring, sv: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](sv: ptr StringValue[LEN_PLUS_ONE], s: string): bool {.inline, noSideEffect.} =
  ## Compares a StringValue to a cstring
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](s: string, sv: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares a cstring to a StringValue
  let cs: cstring = s
  result = (cast[pointer](cs) != nil) and (c_strcmp(cast[cstring](sv), cs) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](addr b)) == 0)

proc `==`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](b)) == 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a, b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](addr b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](unsafeAddr b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](addr b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a, b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](unsafeAddr b)) < 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a, b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](addr b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](unsafeAddr b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](addr b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a, b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](unsafeAddr b)) <= 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a, b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](unsafeAddr b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](addr b)) < 0)

proc `<`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](b)) < 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a, b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](unsafeAddr b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](unsafeAddr a), cast[cstring](b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: ptr StringValue[LEN_PLUS_ONE], b: var StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](a), cast[cstring](addr b)) <= 0)

proc `<=`*[LEN_PLUS_ONE: static[int]](a: var StringValue[LEN_PLUS_ONE], b: ptr StringValue[LEN_PLUS_ONE]): bool {.inline, noSideEffect.} =
  ## Compares StringValues
  (c_strcmp(cast[cstring](addr a), cast[cstring](b)) <= 0)

proc initStringValue*(cs: cstring, LEN_PLUS_ONE: static[int]): StringValue[LEN_PLUS_ONE] {.inline, noSideEffect.} =
  ## Creates a StringValue
  static:
    assert(LEN_PLUS_ONE >= 1)
  let p = cast[pointer](cs)
  let len = if p == nil: 0 else: len(cs)
  if len >= LEN_PLUS_ONE:
    raise newException(Exception, "cs is too big: " & $len)
  if len == 0:
    result[0] = char(0)
  else:
    copyMem(addr result, p, len+1)

proc initStringValue*(s: string, LEN_PLUS_ONE: static[int]): StringValue[LEN_PLUS_ONE] {.inline, noSideEffect.} =
  let cs: cstring = s
  initStringValue(cs, LEN_PLUS_ONE)

type
  StringValue16* = StringValue[16]
    ## A 16-bytes StringValue (maximum length is 15).
  StringValue32* = StringValue[32]
    ## A 32-bytes StringValue (maximum length is 31).
  StringValue64* = StringValue[64]
    ## A 64-bytes StringValue (maximum length is 63).
  StringValue128* = StringValue[128]
    ## A 128-bytes StringValue (maximum length is 127).
  StringValue256* = StringValue[256]
    ## A 256-bytes StringValue (maximum length is 256).

converter toStringValue*(s: string): StringValue16 {.inline, noSideEffect.} =
  ## Converts a string to a StringValue16.
  result = initStringValue(s, 16)

converter toStringValue*(s: string): StringValue32 {.inline, noSideEffect.} =
  ## Converts a string to a StringValue32.
  result = initStringValue(s, 32)

converter toStringValue*(s: string): StringValue64 {.inline, noSideEffect.} =
  ## Converts a string to a StringValue64.
  result = initStringValue(s, 64)

converter toStringValue*(s: string): StringValue128 {.inline, noSideEffect.} =
  ## Converts a string to a StringValue128.
  result = initStringValue(s, 128)

converter toStringValue*(s: string): StringValue256 {.inline, noSideEffect.} =
  ## Converts a string to a StringValue256.
  result = initStringValue(s, 256)

when isMainModule:
  echo("TESTING StringValue ...")
  let text1 = "abc"
  let text2 = "def"

  var st1 = initStringValue(text1, 5)
  var st2 = initStringValue(text2, 5)
  assert(st1.len == 3)
  assert(st1.cstr == text1.cstring)
  assert(st2.cstr == text2.cstring)
  assert(st1 == text1)
  assert(text1 == st1)
  assert($st1 == text1)
  assert(text1 == $st1)
  assert(st1 != st2)
  assert(st1 < st2)
  assert(st1 <= st2)
  assert(st2 > st1)
  assert(st2 >= st1)
  assert(st1[1] == 'b')
  assert(hash(st1) == hash(text1))

  let cst1 = initStringValue(text1, 5)
  let cst2 = initStringValue(text2, 5)
  assert(cst1.len == 3)
  assert(cst1.unsafeCstr == text1.cstring)
  assert(cst2.unsafeCstr == text2.cstring)
  assert(cst1 == text1)
  assert(text1 == cst1)
  assert($cst1 == text1)
  assert(text1 == $cst1)
  assert(cst1 != cst2)
  assert(cst1 < cst2)
  assert(cst1 <= cst2)
  assert(cst2 > cst1)
  assert(cst2 >= cst1)
  assert(cst1[1] == 'b')
  assert(hash(cst1) == hash(text1))

  let pst1 = addr st1
  let pst2 = addr st2
  assert(pst1.len == 3)
  assert(pst1.cstr == text1.cstring)
  assert(pst2.cstr == text2.cstring)
  assert(pst1 == text1)
  assert(text1 == pst1)
  assert($pst1 == text1)
  assert(text1 == $pst1)
  assert(pst1 != pst2)
  assert(pst1 < pst2)
  assert(pst1 <= pst2)
  assert(pst2 > pst1)
  assert(pst2 >= pst1)
  assert(pst1[1] == 'b')
  assert(hash(pst1) == hash(text1))

  assert(st1 != cst2)
  assert(st1 < cst2)
  assert(st1 <= cst2)
  assert(st2 > cst1)
  assert(st2 >= cst1)
  assert(cst1 != st2)
  assert(cst1 < st2)
  assert(cst1 <= st2)
  assert(cst2 > st1)
  assert(cst2 >= st1)

  assert(st1 != pst2)
  assert(st1 < pst2)
  assert(st1 <= pst2)
  assert(st2 > pst1)
  assert(st2 >= pst1)
  assert(pst1 != st2)
  assert(pst1 < st2)
  assert(pst1 <= st2)
  assert(pst2 > st1)
  assert(pst2 >= st1)

  assert(pst1 != cst2)
  assert(pst1 < cst2)
  assert(pst1 <= cst2)
  assert(pst2 > cst1)
  assert(pst2 >= cst1)
  assert(cst1 != pst2)
  assert(cst1 < pst2)
  assert(cst1 <= pst2)
  assert(cst2 > pst1)
  assert(cst2 >= pst1)

  var st3: StringValue16 = "abc"
  assert(st3 == text1)
  st3[0] = 'd'
  st3[1] = 'e'
  st3[2] = 'f'
  assert(st3 == text2)
  echo("TESTING StringValue done.")
