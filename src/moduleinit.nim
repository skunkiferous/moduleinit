# Copyright 2018 Sebastien Diot.

# This module should serve to control the order of (de)initialisation of
# modules, and the threads they create.

# See README.md for usage.

import locks
import tables

import moduleinit/stringvalue

const MAX_TL_INIT_PROCS = 100
  ## Maximum number of registered InitThreadLocalsProc.

var debugModuleinit* = false
  ## Perform debug output during (de)initialisation?

type
  InitModuleProc* = proc(config: TableRef[string,string]): void {.nimcall, gcsafe.}
    ## A proc that perform a level 1 initialisation of some module.
    ## It receives a table with 'global' configuration parameters.

  DeInitModuleProc* = proc(): void {.nimcall, gcsafe.}
    ## A proc that perform a level 1 deinitialisation of some module.

  InitThreadLocalsProc* = proc(): void {.nimcall, gcsafe.}
    ## A proc that initialises threadvars of some module in a new Thread.

  DeInitThreadLocalsProc* = proc(): void {.nimcall, gcsafe.}
    ## A proc that deinitialises threadvars of some module in a new Thread.

  ModuleInfo* = object
    ## Contains the definition of a module.
    name*: string
      ## The module name
    deps*: seq[string]
      ## The dependencies of the module (optional).
    level1Init*: InitModuleProc
      ## The level 1 initialiser (optional).
    level1DeInit*: DeInitModuleProc
      ## The level 1 deinitialiser (optional).
    threadInit*: InitThreadLocalsProc
      ## The threadvars initialiser (optional).
    threadDeInit*: DeInitThreadLocalsProc
      ## The threadvars deinitialiser (optional).

  ModuleName = StringValue32
    ## This limits module names to 30 characters.

  ModuleConfig = object
    ## Contains the info about a module.
    name: ModuleName
      ## The module name
    depsCount: int
      ## The number of dependencies of this module.
    deps: ptr ptr ModuleConfig
      ## The dependencies of the module.
      ## Dynamically allocated array of ptr ModuleConfig, of length depsCount.
    level1Init: InitModuleProc
      ## The level 1 initialiser.
    level1DeInit: DeInitModuleProc
      ## The level 1 deinitialiser.
    threadInit: InitThreadLocalsProc
      ## The optional threadvars initialiser.
    threadDeInit: DeInitThreadLocalsProc
      ## The optional threadvars de-initialiser.
    initialised: bool
      ## Was this module initialised?
    aliasedTo: ptr ModuleConfig
      ## The "real" module this module is an alias of.
    prevModule: ptr ModuleConfig
      ## The previously registered module.

var initLock: Lock
  ## Lock to allow safe multi-threaded use of moduleinit.
  ## All following global variables are guarded by this lock.

var allInitThreadLocalsProcs: array[MAX_TL_INIT_PROCS,InitThreadLocalsProc]
  ## All registered InitThreadLocalsProc
var allInitThreadLocalsProcModules: array[MAX_TL_INIT_PROCS,ModuleName]
  ## All registered InitThreadLocalsProc module names
var registeredInitThreadLocalsProcs: int = 0
  ## Number of registered InitThreadLocalsProc.

var allDeInitThreadLocalsProcs: array[MAX_TL_INIT_PROCS,DeInitThreadLocalsProc]
  ## All registered DeInitThreadLocalsProc
var allDeInitThreadLocalsProcModules: array[MAX_TL_INIT_PROCS,ModuleName]
  ## All registered DeInitThreadLocalsProc module names
var registeredDeInitThreadLocalsProcs: int = 0
  ## Number of registered DeInitThreadLocalsProc.

var lastModule: ptr ModuleConfig
  ## The last registered module.

var initialised: bool = false
  ## Was this process already initialised?

var initialisedThreads = 0
  ## Number of currently running initialised threads.

var threadName {.threadvar.}: string
  ## Was this thread already initialised?


initLock(initLock)

proc inc[T](p: var ptr T) {.inline.} =
  p = cast[ptr T](cast[ByteAddress](p) +% sizeof(T))

proc findOrCreateModule(name: string): ptr ModuleConfig =
  ## Searches for a module with the given name, and returns the ptr to it.
  # If not found, creates a new one.
  var mn: ModuleName = name
  result = lastModule
  while not result.isNil:
    if result.name == mn:
      return result
    result = result.prevModule
  # New module!
  result = createShared(ModuleConfig,1)
  result.name = mn
  result.depsCount = -1 # Mark it as "dummy"
  result.prevModule = lastModule
  lastModule = result

proc initModule(m: ptr ModuleConfig, info: ModuleInfo) =
  ## Initialises a ModuleConfig object
  m.depsCount = if info.deps.isNil: 0 else: len(info.deps)
  if m.depsCount > 0:
    m.deps = createShared(ptr ModuleConfig, m.depsCount)
    var p = m.deps
    for i in 0..<m.depsCount:
      p[] = findOrCreateModule(info.deps[i])
      inc p
  m.level1Init = info.level1Init
  m.level1DeInit = info.level1DeInit
  m.threadInit = info.threadInit
  m.threadDeInit = info.threadDeInit
  m.initialised = false
  if debugModuleinit:
    echo("Module '" & info.name & "' registered in moduleinit.")

proc registerModule*(info: ModuleInfo): bool =
  ## Registers a module, with it's name, dependencies, initialisers,
  ## deinitialisers, thread initialiser and thread deinitialiser.
  ## All parameters are optional, except the name, which cannot be nil or
  ## empty.
  ## Returns true on the first call. Other calls return false and do nothing.
  if info.name.isNil:
    raise newException(Exception, "name is nil!")
  if len(info.name) == 0:
    raise newException(Exception, "name is empty!")
  var mn: ModuleName = info.name
  result = false
  acquire(initLock)
  try:
    if initialised:
      raise newException(Exception, "Process already initialised!")
    var m = lastModule
    while not m.isNil:
      if m.name == mn:
        if m.depsCount == -1:
          # Was only registered as dummy...
          result = true
          initModule(m, info)
        return
      m = m.prevModule
    # New module!
    result = true
    m = createShared(ModuleConfig,1)
    initModule(m, info)
    m.name = mn
    m.prevModule = lastModule
    lastModule = m
  finally:
    release(initLock)

proc registerModule*(name: string,
    deps: seq[string],
    level1Init: InitModuleProc = nil,
    level1DeInit: DeInitModuleProc = nil,
    threadInit: InitThreadLocalsProc = nil,
    threadDeInit: DeInitThreadLocalsProc = nil): bool =
  ## Registers a module, with it's name, dependencies, initialisers,
  ## deinitialisers, thread initialiser and thread deinitialiser.
  ## All parameters are optional, except the name, which cannot be nil or
  ## empty.
  ## Returns true on the first call. Other calls return false and do nothing.
  var info: ModuleInfo
  info.name = name
  info.deps = deps
  info.level1Init = level1Init
  info.level1DeInit = level1DeInit
  info.threadInit = threadInit
  info.threadDeInit = threadDeInit
  registerModule(info)

proc registerModule*(name: string, deps: varargs[string]): bool =
  ## Registers a module, with it's name and dependencies.
  ## Returns true on the first call. Other calls return false and do nothing.
  registerModule(name, @deps)

proc buildDependencies(modules: seq[ptr ModuleConfig]): string =
  ## Lists the dependencies, for debug info.
  result = ""
  var gsep = ""
  for m in modules:
    var s = gsep
    gsep = ", "
    s = s & $m.name & " => ["
    var p = m.deps
    var dsep = ""
    for d in 0..<m.depsCount:
      s = s & dsep & $p[].name
      dsep = ", "
      inc p
    s = s & "]"
    result = result & s

proc sortModules(modules: seq[ptr ModuleConfig],
    aliases: TableRef[string,string]): seq[ptr ModuleConfig] =
  ## Sort all modules, based on their dependencies.
  result = newSeq[ptr ModuleConfig]()
  var todo = newSeq[ptr ModuleConfig]()
  for m in modules:
    if m.aliasedTo.isNil:
      todo.add(m)
    else:
      # At this point, module aliases have been resolved, so that we don't need
      # them anymore.
      deallocShared(m)
  while len(todo) > 0:
    var undone = newSeq[ptr ModuleConfig]()
    for m in todo:
      var addToResult = true
      var p = m.deps
      for x in 0..<m.depsCount:
        if not result.contains(p[]):
          addToResult = false
          break
        inc p
      if addToResult:
        result.add(m)
      else:
        undone.add(m)
    if len(todo) == len(undone):
      raise newException(Exception,
        "Failed to sort modules according to their (circular?) dependencies: "&
        buildDependencies(todo))
    todo = undone
  # Use lastModule to point to the "highest" (last) initialised module.
  var prevModule: ptr ModuleConfig = nil
  for m in result:
    m.prevModule = prevModule
    prevModule = m
  lastModule = prevModule

proc runModuleInitChecks(m: ptr ModuleConfig, initialised: bool) =
  ## Runs one module (de)initialisers checks.
  # In both cases, when running initialisation OR deinitialisation, it is
  # expected that this can only happen if all the dependencies are currently
  # initialised...
  let depsInitialised = true
  if m.initialised != initialised:
    raise newException(Exception, "Expected initialised to be " &
      $initialised & " for module " & $m.name & " but was " &
      $m.initialised)
  if m.depsCount > 0:
    var p = m.deps
    for d in 0..<m.depsCount:
      if p.initialised != depsInitialised:
        # This should not happen, if modules is correctly sorted.
        raise newException(Exception, "initialised " & $p.initialised &
          " of module " & $p.name & " was expected to be " & $depsInitialised &
          " before setting " & $m.name & " initialised to " & $initialised)
      inc p

proc runInit(modules: seq[ptr ModuleConfig], config: TableRef[string,string]) =
  ## Runs all module initialisers.
  # TODO Failure here should cause appropriate denitialisers to be called.
  for m in modules:
    runModuleInitChecks(m, false)
    if not m.level1Init.isNil:
      if debugModuleinit:
        echo("Module '" & $m.name & "' about to be initialised...")
      m.level1Init(config)
    m.initialised = true

proc runDeInit() =
  ## Runs all module deinitialisers.
  # TODO Failure here should still try to run all denitialisers.
  var m = lastModule
  while m != nil:
    runModuleInitChecks(m, true)
    if not m.level1DeInit.isNil:
      if debugModuleinit:
        echo("Module '" & $m.name & "' about to be deinitialised...")
      m.level1DeInit()
    m.initialised = false
    m = m.prevModule
  m = lastModule
  while m != nil:
    let d = m
    m = m.prevModule
    if d.deps != nil:
      deallocShared(d.deps)
    deallocShared(d)
  lastModule = nil

proc resolveAliases(aliases: TableRef[string,string],
    modules: seq[ptr ModuleConfig], aliased: seq[ptr ModuleConfig]) =
  ## Resolve aliases, after finding all modules.
  for a in aliased:
    let mn = $a.name
    let mappedTo = aliases[mn]
    if mappedTo.isNil or len(mappedTo) == 0:
      raise newException(Exception, "Aliased module " & mn &
        " maps to nothing!")
    var m: ptr ModuleConfig = nil
    for n in modules:
      if $n.name == mappedTo:
        if aliased.contains(n):
          raise newException(Exception, "Aliased module " & mn &
            " maps to other aliased module " & mappedTo)
        m = n
        break
    if not m.isNil:
      a.aliasedTo = m
    else:
      raise newException(Exception, "Aliased module " & mn &
        " maps to unknown module " & mappedTo)
  for n in modules:
    var p = n.deps
    for x in 0..<n.depsCount:
      let a = p[].aliasedTo
      if not a.isNil:
        p[] = a
      inc p

proc findRegisteredModules(aliases: TableRef[string,string],
    noinit: openArray[string]): seq[ptr ModuleConfig] =
  ## Finds all registered modules.
  result = newSeq[ptr ModuleConfig]()
  var aliased = newSeq[ptr ModuleConfig]()
  var m = lastModule
  while not m.isNil:
    if m.depsCount == -1:
      # Was only registered as dummy!
      let mn = $m.name
      # We depend on stringvalue, so it cannot be registered explicitly, but
      # we pretend it was in noinit.
      var found = ("stringvalue" == mn)
      for ni in noinit:
        if ni == mn:
          found = true
      if not found and not aliases.isNil and aliases.contains(mn):
        found = true
        aliased.add(m)
      if found:
        m.depsCount = 0
      else:
        raise newException(Exception, "Module " & mn &
          " is a dependency but was not registered!")
    result.add(m)
    m = m.prevModule
  # Now, deal with aliases
  resolveAliases(aliases, result, aliased)

proc installTLInitialisers(sorted: seq[ptr ModuleConfig]) =
  ## Finds all thread local (de)initialisers, and set them as globals, so they
  ## can be executed when creating and destroying threads.
  var tli = 0
  var tld = 0
  for m in sorted:
    if not m.threadInit.isNil:
      if tli == MAX_TL_INIT_PROCS:
        raise newException(Exception, "Too many InitThreadLocalsProc!")
      allInitThreadLocalsProcs[tli] = m.threadInit
      allInitThreadLocalsProcModules[tli] = m.name
      inc tli
    if not m.threadDeInit.isNil:
      if tld == MAX_TL_INIT_PROCS:
        raise newException(Exception, "Too many DeInitThreadLocalsProc!")
      allDeInitThreadLocalsProcs[tld] = m.threadDeInit
      allDeInitThreadLocalsProcModules[tld] = m.name
      inc tld
  registeredInitThreadLocalsProcs = tli
  registeredDeInitThreadLocalsProcs = tld

proc runThreadLocalDeInitialisers*() =
  ## Runs all DeInitThreadLocalsProcs.
  ## Only call this after all de-initialisers have been registered.
  if threadName.isNil:
    # TODO This should not happpen; warn?
    return
  var deinitialisers: array[MAX_TL_INIT_PROCS,DeInitThreadLocalsProc]
  var count: int
  acquire(initLock)
  try:
    if not initialised:
      raise newException(Exception, "Process not yet initialised!")
    deinitialisers = allDeInitThreadLocalsProcs
    count = registeredDeInitThreadLocalsProcs
    dec initialisedThreads
  finally:
    release(initLock)
  for i in countdown(count-1,0):
    # TODO Catch and ignore (log?) failures here?
    if debugModuleinit:
      # Unsynchronized access (to save copying big array)! Crossing fingers...
      echo("Module '" & $allInitThreadLocalsProcModules[i] & "' about to be thread-deinitialised...")
    deinitialisers[i]()
  threadName = nil

proc runThreadLocalInitialisers*(name: string, autoRunTLDeinitialisers = true) =
  ## Runs all InitThreadLocalsProcs.
  ## Only call this after all initialisers have been registered.
  if not threadName.isNil:
    # Because the user does not have control over all thread creations, it is
    # allowed to call runThreadLocalInitialisers() multiple times for the same
    # thread.
    return
  var initialisers: array[MAX_TL_INIT_PROCS,InitThreadLocalsProc]
  var count: int
  acquire(initLock)
  try:
    if not initialised:
      raise newException(Exception, "Process not yet initialised!")
    initialisers = allInitThreadLocalsProcs
    count = registeredInitThreadLocalsProcs
    inc initialisedThreads
  finally:
    release(initLock)
  if name.isNil or len(name) == 0:
    threadName = $getThreadId()
  else:
    threadName = name
  for i in 0..<count:
    # TODO what do we do on failure here?
    if debugModuleinit:
      # Unsynchronized access (to save copying big array)! Crossing fingers...
      echo("Module '" & $allInitThreadLocalsProcModules[i] & "' about to be thread-initialised...")
    initialisers[i]()
  if autoRunTLDeinitialisers:
    onThreadDestruction(runThreadLocalDeInitialisers)

proc getThreadName*(): string =
  ## Returns the name used to register this thread.
  ## nil if unknown.
  return threadName

proc runInitialisers*(config: TableRef[string,string], noinit: varargs[string]) =
  ## Should be called when the level 0 initialisation was complete.
  ## It is assumed, that all modules that are dependencies, were also
  ## registered, or are included as 'noinit' parameters. Alternatively, they
  ## could also be mapped in 'config', as aliases to 'real' modules.
  ## Beyond aliases mapping, 'config' can contain any data that could be used
  ## to initialise modules. We recommend using "modulename.property" as key, to
  ## minimize the chance of conflicts.
  ## Otherwise, an exception is raised.
  acquire(initLock)
  try:
    if initialised:
      raise newException(Exception, "Process already initialised!")
    var config2 = if config.isNil: newTable[string,string]() else: config
    var modules = findRegisteredModules(config2, noinit)
    let sorted = sortModules(modules, config2)
    installTLInitialisers(sorted)
    runInit(sorted, config2)
    initialised = true
  finally:
    release(initLock)
  # Also initialise thread-locals in main thread.
  runThreadLocalInitialisers("main", false)

proc runDeInitialisers*() =
  ## Should be called closing the process.
  ## In theory, if everything is correctly coded, it should be possible to run
  ## multiple cycles of "MainModule.level0InitModuleXXX()", runInitialisers()
  ## and runDeInitialisers() in the same process.
  acquire(initLock)
  try:
    if not initialised:
      raise newException(Exception, "Process not yet initialised!")
    if initialisedThreads > 1:
      # "> 1" because there is still the main thread.
      raise newException(Exception, $initialisedThreads &
         " initialised threads are still running!")
  finally:
    release(initLock)
  # Also deinitialise thread-locals in main thread.
  # Since runThreadLocalDeInitialisers() also uses the lock, we must call it
  # outside the lock.
  runThreadLocalDeInitialisers()
  acquire(initLock)
  try:
    runDeInit()
    for i in 0..<registeredInitThreadLocalsProcs:
      allInitThreadLocalsProcs[i] = nil
    registeredInitThreadLocalsProcs = 0
    for i in 0..<registeredDeInitThreadLocalsProcs:
      allDeInitThreadLocalsProcs[i] = nil
    registeredDeInitThreadLocalsProcs = 0
    initialised = false
  finally:
    release(initLock)
  # After this point, it should be possible to run the main module
  # level0InitModuleXXX(), and then runInitialisers() again.
