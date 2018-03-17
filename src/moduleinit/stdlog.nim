# Copyright 2018 Sebastien Diot.

# Module stdlog

# Initialises the stdlib logging system.

# Since logging is IMHO essential to most apps, I've decided to add an optional
# module for this directly in the moduleinit package.

import logging
import segfaults
import strutils
import tables

import moduleinit
import moduleinit/anyvalue
import moduleinit/stringvalue


const CONSOLE_FORMAT_PROP* = "stdlog.console.format"
  ## Name of config property that specifies the console format, if not default.

const DEFAULT_CONSOLE_FORMAT* = "$datetime\t$levelname\t$thread\t"
  ## Default console format.

const CONSOLE_LEVEL_PROP* = "stdlog.console.level"
  ## Name of config property that specifies the console log level, if not
  ## default.
  ## Level "none" will disable console logging.

const DEFAULT_CONSOLE_LEVEL* = Level.lvlInfo
  ## Default console log level.

const FILE_NAME_PROP* = "stdlog.file.name"
  ## Name of config property that specifies the file name, if not default.

const FILE_FORMAT_PROP* = "stdlog.file.format"
  ## Name of config property that specifies the file format, if not default.

const DEFAULT_FILE_FORMAT* = "$datetime\t$levelname\t$thread\t"
  ## Default file format.

const FILE_MAX_LINES_PROP* = "stdlog.file.maxLines"
  ## Name of config property that specifies the maximum number of file lines,
  ## if not default.

const DEFAULT_FILE_MAX_LINES* = -1
  ## Default maximum file lines. -1 means no maximum, otherwise, we use a
  ## rolling logger.

const FILE_LEVEL_PROP* = "stdlog.file.level"
  ## Name of config property that specifies the file log level, if not default.
  ## Level "none" will disable file logging.

const DEFAULT_FILE_LEVEL* = Level.lvlInfo
  ## Default file log level.

const PRE_INIT_CONSOLE_FORMAT = "$datetime\t$levelname\t<preinit>\t"
  ## "Pre-init" console log format.


var globalConsoleLevel: Level
  ## Log level to use for console logging.
var globalConsoleFmt: StringValue64
  ## Format to use for console logging.
var consoleLogger {.threadvar.}: Logger
  ## Currently active console logger.


var globalFileName: StringValue64
  ## Name to use for file logging.
var globalFileLevel: Level
  ## Log level to use for file logging.
var globalFileFmt: StringValue64
  ## Format to use for file logging.
var globalFileMaxLines: int
  ## Format to use for file logging.
var fileLogger {.threadvar.}: Logger
  ## Currently active file (normal) logger.
var rollingFileLogger {.threadvar.}: Logger
  ## Currently active file rolling logger.


proc loggingInfoLog(msg: string): void {.nimcall, gcsafe.} =
  ## moduleinit INFO log(), using logging.
  info(msg)

proc loggingErrorLog(msg: string): void {.nimcall, gcsafe.} =
  ## moduleinit ERROR log(), using logging.
  error(msg)

proc threadInitStdlog(): void {.nimcall, gcsafe.} =
  ## Initialises thread-local logging, based on chosen format and log level.
  let threadName = getThreadName()
  if globalConsoleLevel != Level.lvlNone:
    let cfmt = ($globalConsoleFmt).replace("$thread", threadName)
    if consoleLogger.isNil:
      consoleLogger = newConsoleLogger(globalConsoleLevel, cfmt)
      addHandler(consoleLogger)
    else:
      consoleLogger.levelThreshold = globalConsoleLevel
      consoleLogger.fmtStr = cfmt
  if globalFileLevel != Level.lvlNone:
    let ffmt = ($globalFileFmt).replace("$thread", threadName)
    if globalFileMaxLines > 0:
      if rollingFileLogger.isNil:
        rollingFileLogger = newRollingFileLogger(filename = $globalFileName, levelThreshold =
          globalFileLevel, fmtStr = ffmt,  maxLines = globalFileMaxLines)
        addHandler(rollingFileLogger)
      else:
        rollingFileLogger.levelThreshold = globalFileLevel
        rollingFileLogger.fmtStr = ffmt
        # TODO maxLines not public
        #rollingFileLogger.maxLines = globalFileMaxLines
        # TODO Cannot change file name easily.
      if not fileLogger.isNil:
        fileLogger.levelThreshold = Level.lvlNone
    else:
      if fileLogger.isNil:
        fileLogger = newFileLogger(filename = $globalFileName, levelThreshold =
          globalFileLevel, fmtStr = ffmt)
        addHandler(fileLogger)
      else:
        fileLogger.levelThreshold = globalFileLevel
        fileLogger.fmtStr = ffmt
        # TODO Cannot change file name easily.
      if not rollingFileLogger.isNil:
        rollingFileLogger.levelThreshold = Level.lvlNone

proc threadDeInitStdlog(): void {.nimcall, gcsafe.} =
  ## Deinitialises thread-local logging.
  if not consoleLogger.isNil:
    consoleLogger.levelThreshold = Level.lvlNone
  if not fileLogger.isNil:
    fileLogger.levelThreshold = Level.lvlNone
  if not rollingFileLogger.isNil:
    rollingFileLogger.levelThreshold = Level.lvlNone

proc level1InitModuleStdlog(config: TableRef[string,AnyValue]): void {.nimcall, gcsafe.} =
  ## Initialises module stdlog at level 1.

  # First, we prepare console logging.
  var cfmt = $(config.getOrDefault(CONSOLE_FORMAT_PROP))
  if cfmt.isNil or len(cfmt) == 0 or (cfmt == "nil"):
    cfmt = DEFAULT_CONSOLE_FORMAT
    warn("No console format specified; using default console format")
  globalConsoleFmt = cfmt
  globalConsoleLevel = DEFAULT_CONSOLE_LEVEL
  var clvl = $(config.getOrDefault(CONSOLE_LEVEL_PROP))
  if not clvl.isNil and len(clvl) > 0 and (clvl != "nil"):
    try:
      globalConsoleLevel = parseEnum[Level](clvl)
      # Still using pre-init logging...
      info("Using specified console logging level: '" & $globalConsoleLevel & "'")
    except:
      # Still using pre-init logging...
      error("Bad console logging level: '" & clvl & "'; using default console logging level")
  else:
    # Still using pre-init logging...
    warn("No console logging level specified; using default console logging level")

  # Then, we prepare file logging.
  var ffmt = $(config.getOrDefault(FILE_FORMAT_PROP))
  if ffmt.isNil or len(ffmt) == 0 or (ffmt == "nil"):
    ffmt = DEFAULT_FILE_FORMAT
    warn("No file format specified; using default file format")
  globalFileFmt = ffmt
  globalFileLevel = DEFAULT_FILE_LEVEL
  globalFileMaxLines = DEFAULT_FILE_MAX_LINES
  var flvl = $(config.getOrDefault(FILE_LEVEL_PROP))
  if not flvl.isNil and len(flvl) > 0 and (flvl != "nil"):
    try:
      globalFileLevel = parseEnum[Level](flvl)
      # Still using pre-init logging...
      info("Using specified file logging level: '" & $globalFileLevel & "'")
    except:
      # Still using pre-init logging...
      error("Bad file logging level: '" & flvl & "'; using default file logging level")
  else:
    # Still using pre-init logging...
    warn("No file logging level specified; using default file logging level")
  var fml = $(config.getOrDefault(FILE_MAX_LINES_PROP))
  if not fml.isNil and len(fml) > 0 and (fml != "nil"):
    try:
      globalFileMaxLines = parseInt(fml)
      # Still using pre-init logging...
      info("Using specified file max lines: '" & fml & "'")
    except:
      # Still using pre-init logging...
      error("Bad file max lines: '" & fml & "'; using default file max lines")
  var fname = $(config.getOrDefault(FILE_NAME_PROP))
  if fname.isNil or len(fname) == 0 or (fname == "nil"):
    fname = defaultFilename()
    warn("No file name specified; using default file name '" & fname & "'")
  globalFileName = fname

  # Logging "early" initialised; normally happens *after* all level 1 init.
  threadDeInitStdlog()
  threadInitStdlog()

proc level0InitModuleStdlog*(): void {.nimcall, gcsafe.} =
  ## Registers module stdlog at level 0.
  if registerModule("stdlog", nil, level1InitModuleStdlog, nil,
      threadInitStdlog, threadDeInitStdlog):
    # We cheat; we perform default logging initialisation, so that we don't
    # loose log events, until we get to level 1.
    consoleLogger = newConsoleLogger(Level.lvlInfo, PRE_INIT_CONSOLE_FORMAT)
    addHandler(consoleLogger)
    # Now that we have to logging configured, we also replace moduleinit own
    # logging.
    if isDefaultModuleinitLogging():
      info("Replacing moduleinit own logging with stdlib logging")
      loginfo = loggingInfoLog
      logerror = loggingErrorLog
