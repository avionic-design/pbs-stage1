package = linux
version = 4.8

major = $(word 1,$(subst ., ,$(version)))

location = https://www.kernel.org/pub/linux/kernel/v$(major).x
tarballs = $(package)-$(version).tar.xz

include packages/target-package.mk

ifeq ($(arch),aarch64)
  arch = arm64
endif

ifeq ($(arch),powerpc)
  defconfig = ppc64_defconfig
else
  defconfig = defconfig
endif

ifeq ($(arch),sh4)
  arch = sh
endif

pkg-cwd = $(pkgsrcdir)
conf-cmd = $(MAKE)
conf-goal = $(defconfig)
conf-args = \
	O=target-$(host) \
	ARCH=$(arch)

# There is nothing to build
build-cmd = true
build-args =

install-goal = headers_install
install-args = \
	INSTALL_HDR_PATH=$(sysroot-prefix) \
	$(conf-args)
