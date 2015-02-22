#include <config/config.h>

#include <sys/stat.h>
#include <sys/types.h>
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>

#include <dispatch/dispatch.h>

#include <bsdtests.h>
#include "dispatch_test.h"
#include <dispatch/dispatch.h>
#include <stdio.h>

static dispatch_source_t g_timer;

static void 
test_fin(void *cxt)
{
	test_ptr("test_fin run", cxt, cxt);
	test_stop();
}

static void 
timer_did_fire(void *ctx)
{
	(void)ctx;
	printf("Strawberry fields...\n");
}

static void 
write_completion_handler(void* ctx, dispatch_data_t unwritten_data, int error)
{
	test_ptr("unwritten_data", unwritten_data, NULL);
	test_int32("error", error, 0);

	int fd = (int)(intptr_t)ctx;
	close(fd);

	dispatch_source_cancel(g_timer);
	dispatch_release(g_timer);
	g_timer = NULL;
}

static void
read_completion_handler(void* ctx, dispatch_data_t data, int error)
{
	int fd = (intptr_t)ctx;
	close(fd);

	int devnull = open("/dev/null", O_WRONLY);
	test_long_greater_than_or_equal("devnull", devnull, 0);
	dispatch_write_f_np(devnull, data, dispatch_get_main_queue(),
						(void *)(intptr_t)devnull, write_completion_handler);
}

int
main(int argc, const char *argv[])
{
	(void)argc;
	(void)argv;

	dispatch_test_start("Dispatch nonportable");

	dispatch_source_t timer = dispatch_source_create(
			DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	g_timer = timer;

	dispatch_source_set_event_handler_f(timer, timer_did_fire);
	dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC,
							  0.5 * NSEC_PER_SEC);
	dispatch_set_context(timer, timer);
	dispatch_set_finalizer_f(timer, test_fin);
	dispatch_resume(timer);

	int fd = open("/usr/share/dict/words", O_RDONLY);
	test_long_greater_than_or_equal("fd", fd, 0);

	dispatch_read_f_np(fd, SIZE_MAX, dispatch_get_main_queue(),
					   (void *)(intptr_t)fd, read_completion_handler);

	dispatch_main();
	return 0;
}

