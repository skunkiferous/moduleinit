# Copyright 2018 Sebastien Diot.

# Module test

# Tests moduleinit

# Depends on "stdlog", "cluster", "tcpcluster"
# Maps module alias "cluster.impl" to "tcpcluster"
# Maps module alias "cluster.recv" to "clusterclient"


import logging
import tables

import moduleinit
import moduleinit\stdlog
import cluster
import clusterclient
import tcpcluster

proc level1InitModuleTest(config: TableRef[string,string]): void {.nimcall, gcsafe.} =
  ## Registers module test at level 1.
  info("test level 1 initialised")
  # todo

proc level0InitModuleTest*(): void {.nimcall, gcsafe.} =
  ## Registers module test at level 0.
  # stdlog is special; we want to init it *before* we init ourselves.
  level0InitModuleStdlog()
  if registerModule("test", @["stdlog", "cluster", "clusterclient", "tcpcluster"], level1InitModuleTest):
    level0InitModuleCluster()
    level0InitModuleClusterclient()
    level0InitModuleTcpcluster()
    info("test level 0 initialised")

proc runTest() =
  echo("Registering all modules...")
  level0InitModuleTest()

  var config = newTable[string,string]()
  config[CLUSTER_IMPL_ALIAS] = "tcpcluster"
  config[CLUSTER_RECV_ALIAS] = "clusterclient"
  config[CONSOLE_LEVEL_PROP] = "lvlDebug"
  config[PORT_PROP] = "12345"

  # Default nativesockets setings are OK for us, so "noinit" nativesockets...
  info("Running all initialisers...")
  runInitialisers(config, "nativesockets")

  # stdlib logging now available.
  info("App code runs now...")
  sendHello()

  info("App code done; shuting down...")
  runDeInitialisers()
  # stdlib logging now shutdown(?)
  echo("Shut down complete")

runTest()