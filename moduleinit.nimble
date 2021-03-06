# Package

version       = "0.4.0"
author        = "Sebastien Diot"
description   = "Nim module/thread initialisation ordering library"
license       = "MIT"

srcDir        = "src"

#bin = @["moduleinit"]

# Dependencies

requires "nim >= 0.18.0"

# Tasks

import ospaths
import strutils
task tests, "Runs tests":
  withdir "tests":
    for file in listfiles("."):
      let sf = splitfile(file)
      if (sf.ext == ".nim") and sf.name.startsWith("test"):
        echo("Testing " & file)
        exec "nim c -r --threads:on --verbosity:0 --hints:off " & file
