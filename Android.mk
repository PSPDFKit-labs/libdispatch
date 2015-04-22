LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE		:= libdispatch
LOCAL_C_INCLUDES	:= $(LOCAL_PATH)/android \
LOCAL_C_INCLUDES	:= $(LOCAL_PATH)/android/config \
					   $(LOCAL_PATH)/os \
					   $(LOCAL_PATH)/private \
					   $(LOCAL_PATH)/../libkqueue/include \
					   $(LOCAL_PATH)/../blocksruntime/BlocksRuntime
LOCAL_CFLAGS		:= -fvisibility=hidden -momit-leaf-frame-pointer -fblocks -DHAVE_CONFIG_H
LOCAL_SRC_FILES		:= \
	src/apply.c \
	src/benchmark.c \
	src/data.c \
	src/init.c \
	src/io.c \
	src/object.c \
	src/once.c \
	src/queue.c \
	src/semaphore.c \
	src/source.c \
	src/time.c \
	src/transform.c

ifeq ($(TARGET_ARCH_ABI),x86_64)
	LOCAL_CFLAGS += -DHAVE_GETPROGNAME
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
	LOCAL_CFLAGS += -DHAVE_GETPROGNAME
endif


include $(BUILD_STATIC_LIBRARY)

