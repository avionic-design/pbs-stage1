all:

ifdef TARGET
include targets/$(TARGET).mk

ifeq ($(libc),gnu)
  libc = glibc
endif

export arch cpu os libc abi fp target
endif
include defs.mk

$(prefix)/meta/_host-check: | $(prefix)/meta
	support/prerequisites.sh
	touch $@

host-check: $(prefix)/meta/_host-check

targets += host-check

$(prefix)/meta $(prefix)/tests $(builddir):
	mkdir -p $@

$(prefix)/meta/m4: | $(prefix)/meta
	$(MAKE) -f packages/m4/Makefile install
	touch $@

$(prefix)/meta/gmp: | $(prefix)/meta/m4
	$(MAKE) -f packages/gmp/Makefile install
	touch $@

$(prefix)/meta/mpfr: $(prefix)/meta/gmp
	$(MAKE) -f packages/mpfr/Makefile install
	touch $@

$(prefix)/meta/ppl: $(prefix)/meta/gmp
	$(MAKE) -f packages/ppl/Makefile install
	touch $@

$(prefix)/meta/mpc: $(prefix)/meta/gmp $(prefix)/meta/mpfr
	$(MAKE) -f packages/mpc/Makefile install
	touch $@

gcc-libs: $(prefix)/meta/mpc $(prefix)/meta/ppl

ifneq ($(target),)
$(prefix)/meta/$(target)-linux:
	$(MAKE) -f packages/linux/Makefile install
	touch $@

$(prefix)/meta/$(target)-binutils: | $(prefix)/meta
	$(MAKE) -f packages/binutils/Makefile install
	touch $@

$(prefix)/meta/$(target)-gcc-stage1: $(prefix)/meta/$(target)-binutils $(prefix)/meta/mpc $(prefix)/meta/ppl $(prefix)/meta/$(target)-linux
	$(MAKE) -f packages/gcc/Makefile install-stage1
	touch $@

$(prefix)/meta/$(target)-glibc-stage1: $(prefix)/meta/$(target)-gcc-stage1
	$(MAKE) -f packages/glibc/Makefile install-stage1
	touch $@

$(prefix)/meta/$(target)-uclibc-stage1: $(prefix)/meta/$(target)-gcc-stage1
	$(MAKE) -f packages/uclibc/Makefile install-stage1
	touch $@

$(prefix)/meta/$(target)-gcc-stage1-libgcc: $(prefix)/meta/$(target)-$(libc)-stage1
	$(MAKE) -f packages/gcc/Makefile install-stage1-libgcc
	touch $@

$(prefix)/meta/$(target)-glibc: $(prefix)/meta/$(target)-gcc-stage1-libgcc
	$(MAKE) -f packages/glibc/Makefile install
	touch $@

$(prefix)/meta/$(target)-uclibc: $(prefix)/meta/$(target)-gcc-stage1-libgcc
	$(MAKE) -f packages/uclibc/Makefile install
	touch $@

$(prefix)/meta/$(target)-gcc: $(prefix)/meta/$(target)-$(libc)
	$(MAKE) -f packages/gcc/Makefile install
	touch $@

gcc: $(prefix)/meta/$(target)-gcc

$(prefix)/meta/$(target)-gdb: $(prefix)/meta/ncurses
	$(MAKE) -f packages/gdb/Makefile install
	touch $@

gdb: $(prefix)/meta/$(target)-gdb


$(prefix)/meta/test-$(target)-compiler: | $(prefix)/tests
	$(MAKE) -f tests/Makefile compiler
	touch $@

compiler-test: $(prefix)/meta/test-$(target)-compiler

targets += gcc gdb compiler-test
else
targets += gcc-libs
endif

$(prefix)/meta/libtool:
	$(MAKE) -f packages/libtool/Makefile install
	touch $@

libtool: $(prefix)/meta/libtool

$(prefix)/meta/pkg-config:
	$(MAKE) -f packages/pkg-config/Makefile install
	touch $@

pkgconfig pkg-config: $(prefix)/meta/pkg-config

$(prefix)/meta/ccache:
	$(MAKE) -f packages/ccache/Makefile install
	touch $@

ccache: $(prefix)/meta/ccache

$(prefix)/meta/autoconf:
	$(MAKE) -f packages/autoconf/Makefile install
	touch $@

autoconf: $(prefix)/meta/autoconf

$(prefix)/meta/autoconf-archive:
	$(MAKE) -f packages/autoconf-archive/Makefile install
	touch $@

autoconf-archive: $(prefix)/meta/autoconf-archive

$(prefix)/meta/automake:
	$(MAKE) -f packages/automake/Makefile install
	touch $@

automake: $(prefix)/meta/automake

$(prefix)/meta/ncurses:
	$(MAKE) -f packages/ncurses/Makefile install
	touch $@

ncurses: $(prefix)/meta/ncurses

targets += libtool pkg-config ccache autoconf autoconf-archive automake ncurses

all: $(targets)

uninstall:
	rm -rf $(prefix)/lib/gcc/$(target)
	rm -rf $(wildcard $(prefix)/bin/$(target)-*)
	rm -rf $(prefix)/$(target)
	rm -rf $(wildcard $(prefix)/meta/$(target)-*)

clean-tests:
	$(MAKE) -f tests/Makefile clean
	rm -f $(wildcard $(prefix)/meta/test-*)

clean-%:
	$(MAKE) -f packages/$*/Makefile clean

clean: clean-binutils clean-gdb clean-gcc clean-glibc clean-uclibc clean-linux clean-tests
