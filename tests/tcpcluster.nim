# Copyright 2018 Sebastien Diot.

# Module tcpcluster

# Depends on "logginginit" and "cluster" and stdlib nativesockets
# (let's pretend nativesockets *can* be initialies too)
# Depends on module alias "cluster.recv"

import logging
#import nativesockets
import strutils
import tables

import logginginit
import moduleinit
import cluster

const PORT_PROP* = "tcpcluster.port"

var socket: uint16

proc fakeReply(msg: string) {.thread.} =
  runThreadLocalInitialisers("fakeReply")
  recvMsg(99, "RECIEVED: " & msg)

proc messageSender(node: NodeID, msg: Message) =
  ## Pretends to send a message
  info("Sending message '" & msg & "' to node #" & $node & " ...")
  ## Pretend we received one too
  var thread: Thread[string]
  createThread[string](thread, fakeReply, msg)
  joinThread(thread)

proc openSocket(port: uint16) =
  ## Pretends to open a TCP socket
  echo("Opening server socket on port " & $port & " ...")
  socket = port

proc closeSocket() =
  ## Pretends to close a TCP socket
  echo("Closing server socket on port " & $socket & " ...")

proc level1InitModuleTcpcluster(config: TableRef[string,string]): void {.nimcall, gcsafe.} =
  ## Registers module tcpcluster at level 1.
  sendMsg = messageSender
  var port = 0
  var portStr = config.getOrDefault(PORT_PROP)
  if not portStr.isNil and len(portStr) > 0:
    try:
      port = parseInt(portStr)
    except:
      discard
    if (port <= 0) or (port > int(high(uint16))):
      raise newException(Exception, "Bad value for " & PORT_PROP & ": '" & portStr & "'")
    openSocket(uint16(port))
  else:
    raise newException(Exception, PORT_PROP & " undefined")
  echo("tcpcluster level 1 initialised")

proc level1DeInitModuleTcpcluster(): void {.nimcall, gcsafe.} =
  ## Deinit module tcpcluster.
  closeSocket()
  echo("tcpcluster level 1 deinitialised")

proc level0InitModuleTcpcluster*(): void {.nimcall, gcsafe.} =
  ## Registers module tcpcluster at level 0.
  if registerModule("tcpcluster", @["logginginit", "cluster", CLUSTER_RECV_ALIAS, "nativesockets"],
      level1InitModuleTcpcluster, level1DeInitModuleTcpcluster):
    level0InitModuleLogginginit()
    level0InitModuleCluster()
    # "cluster.recv" is an alias, so no init method to call.
    echo("tcpcluster level 0 initialised")
