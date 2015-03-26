# libdispatch for Linux

pthreads getting you down? [libdispatch](http://libdispatch.macosforge.org),
aka Grand Central Dispatch (GCD) is Apple's high-performance event-handling
library, introduced in OS X Snow Leopard. It provides asynchronous task queues,
monitoring of file descriptor read and write-ability, asynchronous I/O (for
sockets *and* regular files), readers-writer locks, parallel for-loops, sane
signal handling, periodic timers, semaphores and more. You'll want to read over
Apple's [API reference](http://developer.apple.com/library/ios/#documentation/Performance/Reference/GCD_libdispatch_Ref/Reference/reference.html).

### Changes from Apple's official version
I've added the ability to integrate libdispatch's main queue with third-party
run-loops, e.g. GLib's `GMainLoop`.  Call
`dispatch_get_main_queue_handle_np()` to get a file descriptor your run-loop
can monitor for reading; when it becomes readable call
`dispatch_main_queue_drain_np()` to execute the pending tasks.

I've also added missing `_f` variants for several functions in `data.h` and
`io.h` that took [Objective-C blocks](http://developer.apple.com/library/ios/#documentation/cocoa/Conceptual/Blocks/Articles/00_Introduction.html)
only: look for the functions with `_np` appended to them. Although you can make
full use of libdispatch with compilers like GCC that don't support blocks, it
is not advisable to build libdispatch itself with anything other than Clang, as
the dispatch i/o portion cannot be built without compiler support for blocks.

## Build/Runtime Requirements
- [libBlocksRuntime](https://github.com/mheily/blocks-runtime)
- [libpthread_workqueue](https://github.com/mheily/libpwq)
- [libkqueue](https://github.com/mheily/libkqueue)

## Build Requirements
- [CMake](http://cmake.org) >= 2.8.7
- [Python2](http://python.org) >= 2.6
- [Clang](http://llvm.org) >= 3.4

## Getting Started:
On Ubuntu 12.04 LTS or greater, the required dependencies are available via
apt-get. (However it ships with Clang 3.0, which is rather old and is not
tested.)

    sudo apt-get install libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev cmake

    git clone git://github.com/nickhutchinson/libdispatch.git && cd libdispatch
    mkdir libdispatch-build && cd libdispatch-build
    ../configure
    make
    sudo make install

[![Build Status](https://travis-ci.org/nickhutchinson/libdispatch.svg?branch=master)](https://travis-ci.org/nickhutchinson/libdispatch)

## Known Issues
- 2014-10-01 - Dispatch Sources of type `DISPATCH_SOURCE_TYPE_VNODE` are
  unreliable, and should be avoided for now.

## Testing
See the `run-tests.py` script in `testing/`.

## Demo

### forever.c
```cpp
#include <dispatch/dispatch.h>
#include <stdio.h>

static void timer_did_fire(void *context) {
    printf("Strawberry fields...\n");
}

int main(int argc, const char *argv[]) {
    dispatch_source_t timer = dispatch_source_create(
        DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());

    dispatch_source_set_event_handler_f(timer, timer_did_fire);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC,
                              0.5 * NSEC_PER_SEC);
    dispatch_resume(timer);
    dispatch_main();
}
```

    > clang forever.c -I/usr/local/include -L/usr/local/lib -ldispatch -o forever
    > ./forever

    Strawberry fields...
    Strawberry fields...
    Strawberry fields...
    Strawberry fields...
    [...]


## Credits
This port was made possible by Mark Heily and others who contributed the
`libpthread_workqueue` and `libkqueue` libraries that libdispatch depends on, as
well as numerous portability patches floating around the official libdispatch
mailing list, notably <http://lists.macosforge.org/pipermail/libdispatch-dev/2012-August/000676.html>.

