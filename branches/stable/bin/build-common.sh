#!/bin/sh

# This is my script for building a complete cross-compiler toolchain.
# It is based partly on Ray Kelm's script, which in turn was built on
# Mo Dejong's script for doing the same, but with some added fixes.
# The intent with this script is to build a cross-compiled version
# of the current MinGW environment.
#
# Updated by Sam Lantinga <slouken@libsdl.org>

# Use User config, if exist
if [ -f user-build.cfg ] ; then
	# Users directories
	source user-build.cfg
else
	# fall back to default config
	source sample.user-build.cfg
fi

# what flavor are we building?
TARGET=i686-pc-mingw32

# you probably don't need to change anything from here down
TOPDIR=`pwd`
SRCDIR="$SOURCE_DIR"

# where does it go?
if [ "$PREFIX" = "" ] ; then
    echo "Please specify the $""PREFIX directory in user-build.cfg (e.g, /usr/local/mingw32)"
    exit -1
fi

# where does it go?
if [ "$SOURCE_DIR" = "" ] ; then
    echo "Please specify the $""SOURCE_DIR directory in user-build.cfg (e.g, /tmp/$USER/download)"
    exit -1
fi

# coLinux enabled kernel source?
if [ "$COLINUX_TARGET_KERNEL_PATH" = "" ] ; then
    echo "Please specify the $""COLINUX_TARGET_KERNEL_PATH in user-build.cfg (e.g, /tmp/$USER/linux-co)"
    exit -1
fi

# coLinux kernel we are targeting
# KERNEL_DIR: sub-dir in www.kernel.org for the download (e.g. v2.6)
if [ "$KERNEL_DIR" = "" ] ; then
    echo "Please specify the $""KERNEL_DIR in user-build.cfg (e.g. KERNEL_DIR=v2.6"
    exit -1
fi
# KERNEL_VERSION: the full kernel version (e.g. 2.6.10)
if [ "$KERNEL_VERSION" = "" ] ; then
    echo "Please specify the $""KERNEL_VERSION in user-build.cfg (e.g. KERNEL_VERSION=2.6.10"
    exit -1
fi

# Default logfile of building (Append), can overwrite in user-build.cfg
if [ "$COLINUX_BUILD_LOG" = "" ] ; then
    COLINUX_BUILD_LOG="$TOPDIR/build-colinux-$$.log"
fi

# Default install directory
if [ "$COLINUX_INSTALL_DIR" = "" ] ; then
    echo "Please specify the $""COLINUX_INSTALL_DIR in user-build.cfg (e.g, /home/$USER/colinux/dist)"
    exit -1
fi

# These are the files from the SDL website
# need install directory first on the path so gcc can find binutils

PATH="$PREFIX/bin:$PATH"

#
# download a file from a given url, only if it is not present
#

download_file()
{
	# Make sure wget is installed
	if test "x`which wget`" = "x" ; then
		echo "You need to install wget."
		exit 1
	fi
	cd "$SRCDIR"
	if test ! -f $1 ; then
		echo "Downloading $1"
		wget "$2/$1"
		if test ! -f $1 ; then
			echo "Could not download $1"
			exit 1
		fi
	else
		echo "Found $1 in the srcdir $SRCDIR"
	fi
  	cd "$TOPDIR"
}

#
# Show errors from actual logfile, than exit build process
# Arg1: Errorlevel
# Arg2: Error message
#

error_exit()
{
	# Show errors in log file with tail or less
	tail -n 20 $COLINUX_BUILD_LOG
	# less $COLINUX_BUILD_LOG

	echo "$2"
	echo "  - log available: $COLINUX_BUILD_LOG"
	exit $1
}

W32API=w32api-3.1
MINGW_URL=http://heanet.dl.sourceforge.net/sourceforge/mingw
