#!/bin/bash


# This file is part of the ttylinux software.
# The license which this software falls under is GPLv2 as follows:
#
# Copyright (C) 2010-2013 Douglas Jerome <douglas@ttylinux.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place, Suite 330, Boston, MA  02111-1307  USA


# ******************************************************************************
# Definitions
# ******************************************************************************

PKG_URL="http://sourceforge.net/projects/e2fsprogs/files/e2fsprogs/v1.42.7/"
PKG_ZIP="e2fsprogs-1.42.7.tar.gz"
PKG_SUM=""

PKG_TAR="e2fsprogs-1.42.7.tar"
PKG_DIR="e2fsprogs-1.42.7"


# Function Arguments:
#      $1 ... Package name, like "glibc-2.19".


# ******************************************************************************
# pkg_patch
# ******************************************************************************

pkg_patch() {
PKG_STATUS=""
return 0
}


# ******************************************************************************
# pkg_configure
# ******************************************************************************

pkg_configure() {

local CONFIG_BLKID="--disable-libblkid"
local CONFIG_DEFRAG="--enable-defrag"
local TTYLINUX_LDFLAGS="-lblkid"

PKG_STATUS="./configure error"

if [[ x"${TTYLINUX_PACKAGE_E2FSPROGS_HAS_BLKID:-}" == x"y" ]]; then
	CONFIG_BLKID="--enable-libblkid"
	TTYLINUX_LDFLAGS=""
fi

# I don't remember why this is here, maybe to save space, or maybe it didn't
# compile for this platform.
[[ "${TTYLINUX_PLATFORM}" == "wrtu54g_tm" ]] && CONFIG_DEFRAG="--disable-defrag"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
AR="${XBT_AR}" \
AS="${XBT_AS} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CC="${XBT_CC} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
CXX="${XBT_CXX} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
LD="${XBT_LD} --sysroot=${TTYLINUX_SYSROOT_DIR}" \
NM="${XBT_NM}" \
OBJCOPY="${XBT_OBJCOPY}" \
RANLIB="${XBT_RANLIB}" \
SIZE="${XBT_SIZE}" \
STRIP="${XBT_STRIP}" \
CFLAGS="${TTYLINUX_CFLAGS}" \
LDFLAGS="${TTYLINUX_LDFLAGS}" \
./configure \
	--build=${MACHTYPE} \
	--host=${XBT_TARGET} \
	--prefix=/usr \
	--with-root-prefix="" \
	${CONFIG_BLKID} \
	${CONFIG_DEFRAG} \
	--enable-fsck \
	--enable-libuuid \
	--enable-option-checking \
	--enable-rpath \
	--enable-tls \
	--enable-verbose-makecmds \
	--disable-blkid-debug \
	--disable-bsd-shlibs \
	--disable-checker \
	--disable-compression \
	--disable-debugfs \
	--disable-e2initrd-helper \
	--disable-elf-shlibs \
	--disable-imager \
	--disable-jbd-debug \
	--disable-maintainer-mode \
	--disable-nls \
	--disable-profile \
	--disable-resizer \
	--disable-testio-debug \
	--disable-uuidd || return 1

source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_make
# ******************************************************************************

pkg_make() {

PKG_STATUS="make error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	--jobs=${NJOBS} \
	CROSS_COMPILE=${XBT_TARGET}- || return 1
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_install
# ******************************************************************************

pkg_install() {

PKG_STATUS="install error"

cd "${PKG_DIR}"
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_set"
PATH="${XBT_BIN_PATH}:${PATH}" make \
	DESTDIR=${TTYLINUX_SYSROOT_DIR} \
	install || return 1
PATH="${XBT_BIN_PATH}:${PATH}" make \
	DESTDIR=${TTYLINUX_SYSROOT_DIR} \
	install-libs || return 1
source "${TTYLINUX_XTOOL_DIR}/_xbt_env_clr"
cd ..

if [[ -d "rootfs/" ]]; then
	find "rootfs/" ! -type d -exec touch {} \;
	cp --archive --force rootfs/* "${TTYLINUX_SYSROOT_DIR}"
fi

PKG_STATUS=""
return 0

}


# ******************************************************************************
# pkg_clean
# ******************************************************************************

pkg_clean() {
PKG_STATUS=""
return 0
}


# end of file
