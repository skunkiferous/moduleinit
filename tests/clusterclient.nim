# Copyright 2018 Sebastien Diot.

# Module clusterclient

# Depends on "logginginit" and "cluster"

import logging
import tables

import logginginit
import moduleinit
import cluster

proc messageReceiver(node: NodeID, msg: Message) =
  info("Received message '" & msg & "' from node #" & $node)

proc level1InitModuleClusterclient(config: TableRef[string,string]): void {.nimcall, gcsafe.} =
  ## Registers module clusterclient at level 1.
  recvMsg = messageReceiver
  echo("clusterclient level 1 initialised")

proc level0InitModuleClusterclient*(): void {.nimcall, gcsafe.} =
  ## Registers module clusterclient at level 0.
  if registerModule("clusterclient", @["logginginit", "cluster"], level1InitModuleClusterclient):
    level0InitModuleLogginginit()
    level0InitModuleCluster()
    echo("clusterclient level 0 initialised")

proc sendHello*() =
  sendMsg(123, "Hello world!")