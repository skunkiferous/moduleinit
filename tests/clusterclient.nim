# Copyright 2018 Sebastien Diot.

# Module clusterclient

# Depends on "stdlog" and "cluster"

import logging
import tables

import moduleinit
import moduleinit/anyvalue
import moduleinit/stdlog
import cluster

proc messageReceiver(node: NodeID, msg: Message) =
  info("Received message '" & msg & "' from node #" & $node)

proc level1InitModuleClusterclient(config: TableRef[string,AnyValue]): void {.nimcall, gcsafe.} =
  ## Registers module clusterclient at level 1.
  recvMsg = messageReceiver
  info("clusterclient level 1 initialised")

proc level0InitModuleClusterclient*(): void {.nimcall, gcsafe.} =
  ## Registers module clusterclient at level 0.
  if registerModule("clusterclient", @["stdlog", "cluster"], level1InitModuleClusterclient):
    level0InitModuleStdlog()
    level0InitModuleCluster()
    info("clusterclient level 0 initialised")

proc sendHello*() =
  sendMsg(123, "Hello world!")