SHELL:=/bin/bash
UNAME:=$(shell uname | tr '[A-Z]' '[a-z]')
PWD:=$(shell pwd)

BITS?=64
ifeq ($(UNAME), darwin)
  READLINK_ARGS:=""
  PLATFORM_WARNINGS:=-Weverything -Wno-c++98-compat-pedantic -Wno-padded \
	-Wno-missing-prototypes -Wno-poison-system-directories \
	-Wno-global-constructors
  PLATFORM_COPTS:=-std=c++20 -stdlib=libc++ -DTARGET_RT_MAC_CFM=0
  HEADERS:=include
  CC=clang++
  LDFLAGS=-Wl,-fatal_warnings -Wl,-std=c++20 -Wl,-stdlib=libc++
  
else ifeq ($(UNAME), linux)
  READLINK_ARGS:="-f"
  PLATFORM_COPTS:=-mfpmath=sse -std=c++20
  PLATFORM_WARNINGS:=-Wframe-larger-than=16384 -Wno-unused-but-set-variable \
    -Wunused-but-set-parameter -Wvla -Wno-conversion-null \
    -Wno-builtin-macro-redefined -Wno-global-constructors
  HEADERS:=include
  CC=g++
  LDFLAGS=-Wl,--fatal-warnings -stdlib=libstdc++
endif

JAVA_HOME := $(shell \
	[[ -n "$${JAVA_HOME}" ]] || \
	  JAVA_HOME=$$(dirname $$(readlink $(READLINK_ARGS) $$(which java)))/../; \
	[[ "$${JAVA_HOME}" =~ /jre/ ]] && JAVA_HOME=$${JAVA_HOME}/../; \
	[[ -n "$${JAVA_HOME}" ]] || (echo "Cannot find JAVA_HOME" && exit) ; \
	echo $${JAVA_HOME})
AGENT=libtigerprof.o
LIBS=-ldl
BUILD_DIR ?= $(shell mkdir build 2> /dev/null ; echo build)
SRC_DIR:=${PWD}/src
OPT?=-O2
GLOBAL_WARNINGS=-Wall -Werror -Wformat-security -Wno-char-subscripts \
	-Wno-sign-compare -Wno-strict-overflow -Wwrite-strings -Wnon-virtual-dtor \
	-Woverloaded-virtual
GLOBAL_COPTS=-fdiagnostics-show-option -fno-exceptions \
	-fno-omit-frame-pointer -fno-strict-aliasing -funsigned-char \
	-fno-asynchronous-unwind-tables -m$(BITS) -msse2 -g \
	-D__STDC_FORMAT_MACROS
COPTS:=$(PLATFORM_COPTS) $(GLOBAL_COPTS) $(PLATFORM_WARNINGS) \
	$(GLOBAL_WARNINGS) $(OPT)

INCLUDES=-I$(JAVA_HOME)/$(HEADERS)


# LDFLAGS+=-Wl,--export-dynamic-symbol=Agent_OnLoad

SOURCES=$(wildcard $(SRC_DIR)/*.cc)
_OBJECTS=$(SOURCES:.cc=.pic.o)
OBJECTS = $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%,$(_OBJECTS))

$(BUILD_DIR)/%.pic.o: $(SRC_DIR)/%.cc
	$(CC) $(INCLUDES) $(COPTS) -Fvisibility=hidden -fPIC -c $< -o $@

$(AGENT): $(OBJECTS)
	$(CC) $(COPTS) -shared -o $(BUILD_DIR)/$(AGENT) \
	  -Bsymbolic $(OBJECTS) $(LIBS)

all: $(AGENT)

clean:
	rm -rf $(BUILD_DIR)/*

DOCKER_IMAGE_NAME="lightweight_java_profiler/build"
docker-build:
	    @docker build -t $(DOCKER_IMAGE_NAME) .

docker-run:
	    @docker run -t -i -v $(PWD):$(PWD) -w $(PWD) $(DOCKER_IMAGE_NAME) bash
