libdispatch
===========

Later revisions of [libdispatch](http://libdispatch.macosforge.org) at Apple's [official SVN repository](http://svn.macosforge.org/repository/libdispatch) don't build on Linux; the last one that works out-of-the-box is `r199`, but that revision doesn't contain any of the nifty APIs added in OS X Lion, e.g. dispatch I/O channels and concurrent private queues.

This repo applies some patches by Mark Heily, taken from [his post to the libdispatch mailing list](http://lists.macosforge.org/pipermail/libdispatch-dev/2012-August/000676.html), and some other build fixes that I cobbled together. It all seems to work, but ominously, the test suite doesn't build, so who really knows?

Prerequisities
--------------
- [libBlocksRuntime](http://mark.heily.com/project/libblocksruntime)
- [libpthread_workqueue](http://mark.heily.com/project/libpthread_workqueue)
- [libkqueue](http://mark.heily.com/project/libkqueue)
- Clang
- automake/autoconf/libtool

How to build
------------
The following does the job on Ubuntu 12.04:

    sudo apt-get install libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev
    cd /path/to/libdispatch/sources
    sh autogen.sh
    ./configure CFLAGS="-I/usr/include/kqueue" LDFLAGS="-lkqueue -lpthread_workqueue -pthread"
    make
    sudo make install

Testing
-------
The unit tests currently don't build on Linux, and I don't know enough Autotools to fix them myself. But this works:

    cat <<EOSRC>dispatch_test.c
    #include <dispatch/dispatch.h>
    #include <stdio.h>

    void handler(void *ctx) { printf("Strawberry fields\n"); }

    int main(int argc, const char *argv[]) {
      dispatch_source_t timer = dispatch_source_create(
          DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());

      dispatch_source_set_event_handler_f(timer, handler);
      dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC,
                                0.5 * NSEC_PER_SEC);
      dispatch_resume(timer);

      dispatch_main();
      return 0;
    }
    EOSRC

    clang dispatch_test.c -L/usr/local/lib -I/usr/local/include -ldispatch -o dispatchTest
    ./dispatchTest

