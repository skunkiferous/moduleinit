# Copyright 2018 Sebastien Diot.

# Module logginginit

# Initialises the logging system.

import logging
import strutils
import tables

import moduleinit/stringvalue
import moduleinit

const FORMAT_PROP* = "logginginit.format"
const DEFAULT_FORMAT = "$datetime\t$levelname\t"

const LEVEL_PROP* = "logginginit.level"
const DEFAULT_LEVEL = Level.lvlInfo

var globalLogLevel: Level
var globalLogFmt: StringValue128

proc threadInitLogging(): void {.nimcall, gcsafe.} =
  ## Initialises thread-local logging, based on chosen format and log level.
  addHandler(newConsoleLogger(globalLogLevel, $globalLogFmt))
  info("Logging setup for thread " & getThreadName())

proc threadDeInitLogging(): void {.nimcall, gcsafe.} =
  ## Deinitialises thread-local logging.
  info("Logging deinit for thread " & getThreadName())

proc level1InitModuleLogginginit(config: TableRef[string,string]): void {.nimcall, gcsafe.} =
  ## Registers module logginginit at level 1.
  var fmt = config.getOrDefault(FORMAT_PROP)
  if fmt.isNil or len(fmt) == 0:
    fmt = DEFAULT_FORMAT
  globalLogFmt = fmt
  globalLogLevel = DEFAULT_LEVEL
  var lvl = config.getOrDefault(LEVEL_PROP)
  if not lvl.isNil and len(lvl) > 0:
    try:
      globalLogLevel = parseEnum[Level](lvl, DEFAULT_LEVEL)
      echo("Using specified log level: '" & lvl & "'")
    except:
      echo("Bad log level: '" & lvl & "'")
  else:
    echo("No log level specified")
  echo("logginginit level 1 initialised")

proc level1DeInitModuleLogginginit(): void {.nimcall, gcsafe.} =
  ## Deinit module logginginit.
  echo("logginginit level 1 de-initialised")

proc level0InitModuleLogginginit*(): void {.nimcall, gcsafe.} =
  ## Registers module logginginit at level 0.
  if registerModule("logginginit", nil, level1InitModuleLogginginit,
      level1DeInitModuleLogginginit, threadInitLogging, threadDeInitLogging):
    echo("logginginit level 0 initialised")
