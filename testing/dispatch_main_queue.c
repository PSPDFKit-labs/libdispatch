/*
 * Copyright (c) 2008-2011 Apple Inc. All rights reserved.
 *
 * @APPLE_APACHE_LICENSE_HEADER_START@
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * @APPLE_APACHE_LICENSE_HEADER_END@
 */

#include <config/config.h>

#include <stdlib.h>
#include <sys/epoll.h>

#include <bsdtests.h>
#include "dispatch_test.h"

static bool has_run = false;

static void work(void *ctx)
{
	(void)ctx;
	has_run = true;
}

int main(void)
{
	dispatch_test_start("Main queue handle");
	dispatch_queue_handle_t qh = dispatch_get_main_queue_handle_np();
	test_long("Main queue handle", qh >= 0, 1);

	int epoll_fd = epoll_create1(EPOLL_CLOEXEC);

	void *sentinel = &sentinel;
	struct epoll_event ev_in = {EPOLLIN, {sentinel}};
	int result = epoll_ctl(epoll_fd, EPOLL_CTL_ADD, qh, &ev_in);

	struct epoll_event ev_out;
	memset(&ev_out, 0, sizeof(ev_out));
	do {
		result = epoll_wait(epoll_fd, &ev_out, 1, 0);
	} while (result == -1 && errno == EINTR);

	test_long("has event", result, 0);
	dispatch_async_f(dispatch_get_main_queue(), NULL, work);

	do {
		result = epoll_wait(epoll_fd, &ev_out, 1, 0);
	} while (result == -1 && errno == EINTR);

	test_long("has run func", has_run, 0);
	test_ptr("has event", ev_out.data.ptr, sentinel);
	test_long("has event", result, 1);

	dispatch_main_queue_drain_np();

	do {
		result = epoll_wait(epoll_fd, &ev_out, 1, 0);
	} while (result == -1 && errno == EINTR);
	test_long("has event", result, 0);
	test_long("has run func", has_run, 1);

	return 0;
}
