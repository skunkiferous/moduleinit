## moduleinit
nim package that provides module/thread initialisation ordering

#### Function provided by moduleinit:
- Control the order of (de)initialisation of Nim modules
- Control the order of (de)initialisation of threadvars created by Nim modules
- Use "modules aliases" / "virtual modules" for complex (de)initialisation
- Circular dependencies are NOT supported, nor is there any plan to do so
- A utility "string value" helper module
- An optional "stdlog" sub module, which sets up Nim standard logging
- TODO: Explicit support for dynamically loaded libraries


#### Documentation

Module initialisation is broken into "level 0" initialisation and "level 1"
initialisation. There is only one level of thread initialisation.

Level 0 initialisation is what the runtime does for you. We don't really
have any control over it. We just know that it is done, by the time we can
actually access a module. Level 0 is used for the "discovery" of all modules,
so in Level 0, we should make sure to access all modules we need at least
once. To make this easy, all modules should provide an init proc like this:

```nim
proc level0InitModuleXXX*(): void =
  ## Registers module xxx.
  if registerModule("xxx", @["yyy","zzz"], level1InitModuleXXX,
      level1DeInitModuleXXX, threadInitXXX, threadDeInitXXX):
    level0InitModuleYYY()
    level0InitModuleZZZ()
```

Modules yyy and zzz are assumed to be direct dependencies of xxx.
Everything is "optional", except the name. The order of the dependencies
should not make any difference in level 0.

level0InitModuleXXX() can be called any number of times, once for each direct
dependent module. It should register itself with it's name, the names of it's
direct dependencies, and it's own higher-level (de)init procs. No resource
should be allocated in level0InitModuleXXX(); all resources, and in
particular threads, should be allocated in level1InitModuleXXX().
level0InitModuleXXX() should not do anything else, and leave any
initialisation that depends on other modules for level1InitModuleXXX() ...
(note that consts are safe to use on level 0).

threadInitXXX is a proc pointer, that will be called on thread creation, to
ensure safe initialisation of your threadvars. This requires cooperation of
the code that creates the threads.

registerModule() will return true only on the first call, so that we avoid
calling the level0InitModule() of dependencies more than once.

Once the main module level0InitModuleXXX() has been called, we can assume
that all level0InitModuleXXX() procs were called. At that point, we know all
the registered modules, can assume that no other module is used, and can move
to level 1 initialisation. This is done with runInitialisers().
runDeInitialisers() should be called before shutting down (or "resetting").

level1InitModuleXXX() are never called directly by your code. A level 1 init
proc is called, when all level 1 init procs of it's dependencies have been
called. This proceeds, until all init procs were called (or a failure
happens). Deinitialisation works the same way, but backwards.

When creating a new thread, make sure to call runThreadLocalInitialisers()
as the first line of code. This will ensure that your threadInitXXX() proc,
and those of your dependencies, are called, in the right order.
runThreadLocalInitialisers() can also safely be called within threads in
which your code runs, but which were created by modules outside your control.
For example, the asyncdispatch/asyncnet standard modules. This works, because
runThreadLocalInitialisers() "remembers" if it was called already. Calls to
runThreadLocalDeInitialisers() are normally performed automatically, by
registering a thread-death handler in runThreadLocalInitialisers().
(The main thread is a special case.)

If your code use some xxx module over which you have no control, for example
a stdlib module, but that module also needs some initialisation, you can just
create a xxxinit module, that registers itself and takes care of the required
initialisation. Also use "xxxinit" as module name and in the dependencies.

OTOH, if some code depends on a third-party module, without dependencies or
initialisation requirements, you can just add the name to runInitialisers(),
as a 'noinit' parameter. We basically pretend, that the modules in 'noinit'
were initialised.

To allow things like dependency injection, or runtime composition, or if the
initialisation requires configuration parameters, or when using multi-step
initialisation, "modules aliases" can be used. A module alias is an abstract
module name that is mapped at runtime to a real module. Since it is abstract,
it cannot actually be accessed by the module "depending" on it, but allows
the dependent module to express their dependency on something that "someone
else" must provide.

For example, if you define an "interface" module, which exposes proc pointers
such that multiple implementations can be defined, and accessed indirectly
through the interface module, you can define an alias for the implementation.
Concretely, if you have a "cluster" interface module, you can, by convention,
refer to the implementation as "cluster.impl". Any module that needs to
access the cluster must then depend both on "cluster" which is available to
them at compile time, and "cluster.impl" which is just a convenient way to
make sure that cluster is initialised to an actual implementation before your
module tries to access the cluster. The main (presumably) application module
will map "cluster.impl" to a concrete module, for example "tcpcluster". The
cluster module can then come with multiple implementations, including
third-party implementations, that the application can choose from at runtime.

If tcpcluster itself requires a "server" port and IP address to be set
before it can initialise itself, it could depend, again by convention, on
"tcpcluster.config", which could either be mapped, or directly implemented,
by the application code.

Effectively, in the current version, it would be possible to register
multiple "virtual" modules in a "physical" module file, since the
registration only requires names and proc pointers.

Any module that allocates resources, and in particular threads, in it's init
proc, should free those resources in it's deinit proc. Note that deinit might
also be called in the case of an initialisation failure (TODO), such that it
is best to not assume full successful initialisation when running deinit.
Implementing deinit procs make it possible for an application to re-configure
at runtime, without leaking resources.

Note that circular dependencies are NOT supported, nor is there any plan to
do so. Breaking modules into interface and implementation, along with using
module aliases and "virtual" modules, should solve most circular dependencies
problems.

There currently isn't explicit support for dynamically loaded libraries, but
this module is designed to support them, such that this can be added in the
future.

I have considered if it would be possible to find the dependencies
automatically at compile time, by scanning the imports, but I believe this
would be problematic, since all the stdlib imports would also be added as
dependencies, while not having been explicitly registered, causing the
initialisation to fail on "missing modules". Also, since module aliases are
a core part of the design, and those dependencies can (presumably) not be
detected automatically, I believe that specifying the dependencies "manually"
is (currently) the best solution. The main downside is that you have to
remember to update level0InitModuleXXX() when changing the imports.
