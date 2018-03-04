# Copyright 2018 Sebastien Diot.

# Module cluster

# A cluster API.
#
# Clients should also depend on "cluster.impl" module alias.
# Clients should define the "cluster.recv" alias.
# "cluster.impl" must depend on "cluster.recv".

import moduleinit

const CLUSTER_IMPL_ALIAS* = "cluster.impl"
const CLUSTER_RECV_ALIAS* = "cluster.recv"

type
  Message* = string
  NodeID* = int

  SendMessageProc* = proc(node: NodeID, msg: Message): void {.nimcall, gcsafe.}
  RecvMessageProc* = proc(node: NodeID, msg: Message): void {.nimcall, gcsafe.}

var sendMsg* : SendMessageProc
  ## Must be initialised by cluster.impl (module alias)
var recvMsg* : SendMessageProc
  ## Must be initialised by cluster.recv (module alias)

proc level0InitModuleCluster*(): void {.nimcall, gcsafe.} =
  ## Registers module cluster at level 0.
  if registerModule("cluster"):
    echo("cluster level 0 initialised")
