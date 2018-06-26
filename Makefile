# Run sharness tests
#
# Copyright (c) 2016 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#
# NOTE: run with TEST_VERBOSE=1 for verbose sharness tests.

T = $(sort $(wildcard t[0-9][0-9][0-9][0-9]-*.sh))
LIBDIR = lib
SHARNESSDIR = sharness
AGGREGATE = $(LIBDIR)/$(SHARNESSDIR)/aggregate-results.sh

BINS = bin/ipfs
BINS += bin/go-sleep
BINS += bin/go-timeout
BINS += bin/pollEndpoint
BINS += bin/random
BINS += bin/random-files
BINS += bin/ma-pipe-unidir
BINS += bin/multihash
BINS += bin/hang-fds
BINS += bin/iptb

all: aggregate

help:
	@echo "- use 'make' or 'make all' to run all the tests"
	@echo "- use 'make deps' to create an 'ipfs' executable in ../bin"
	@echo "- to run tests manually, make sure to include ../bin in your PATH"

clean: clean-test-results
	@echo "*** $@ ***"

clean-test-results:
	@echo "*** $@ ***"
	-rm -rf test-results

$(T): clean-test-results deps
	@echo "*** $@ ***"
	./$@

aggregate: clean-test-results $(T)
	@echo "*** $@ ***"
	ls test-results/t*-*.sh.*.counts | $(AGGREGATE)

deps: sharness $(BINS) curl

sharness:
	@echo "*** checking $@ ***"
	lib/install-sharness.sh

bin/go-sleep:
	@echo "*** building $@ ***"
	go get -d github.com/chriscool/go-sleep
	go build -o $@ github.com/chriscool/go-sleep

bin/go-timeout:
	@echo "*** building $@ ***"
	go get -d github.com/Kubuxu/go-timeout
	go build -o $@ github.com/Kubuxu/go-timeout

bin/pollEndpoint:
	@echo "*** building $@ ***"
	go get -d github.com/whyrusleeping/pollEndpoint
	go build -o $@ github.com/whyrusleeping/pollEndpoint

bin/random:
	@echo "*** building $@ ***"
	go get -d github.com/jbenet/go-random
	go build -o $@ github.com/jbenet/go-random/random

bin/random-files:
	@echo "*** building $@ ***"
	go get -d github.com/jbenet/go-random-files
	go build -o $@ github.com/jbenet/go-random-files/random-files

bin/ma-pipe-unidir:
	@echo "*** building $@ ***"
	cd dependencies/ma-pipe-unidir && go build -o ../../$@

bin/multihash:
	@echo "*** building $@ ***"
	go get -d github.com/multiformats/go-multihash
	go build -o $@ github.com/multiformats/go-multihash/multihash

gx-path = gx/ipfs/$(shell gx deps find $(1))/$(1)

bin/hang-fds:
	@echo "*** building $@ ***"
	go build -o $@ "$(call gx-path,$(notdir $@))"

bin/iptb:
	@echo "*** building $@ ***"
	go build -o $@ "$(call gx-path,$(notdir $@))"

IPFS_DEF != which ipfs
IPFS_CMD ?= $(IPFS_DEF)

bin/ipfs:
	@echo "*** building $@ ***"
	cd bin && ln -sf $(IPFS_CMD) ipfs

curl:
	@which curl >/dev/null || (echo "Please install curl!" && false)

.PHONY: all help clean clean-test-results $(T) aggregate deps sharness

