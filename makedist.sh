#!/bin/bash
#
# makedist.sh: script to make rottlog release tarball.
# Copyright 2002, 2003, 2004 Stefano Falsetto <falsetto@gnu.org>
# Copyright 2008, 2010 David Egan Evans <sinuhe@gnu.org>
#
# This program is free software.  You can redistribute it, or modify it,
# or both, under the terms of the GNU General Public License version 3
# (or any later version) as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses>.
#

# Declare default variables
MAINPRG="rottlog"
MAINDIR="src/"
VER="ver"
source ./VERSION
VER_FILE="$MAINPRG-$(date "+%d-%m-%Y-%H.%M.%S")"
MAIL="[sinuhe@gnu\.org]"

# Make temp directories for build environment.
mkdir -p tmp
mkdir -p ver/src
mkdir -p tar

# Modify rottlog to match declared variables.
cp -v $MAINDIR/$MAINPRG $VER/$VER_FILE
echo "Updating variables:"
echo "VERSION=$VERSION"
echo "MAINDIR=@MAINDIR"
echo "MAINRC=\$MAINDIR/rc"
echo "STATDIR=/var/lib/rottlog"
echo "DEBUG="
echo
echo -n "rottlog, "
sed -e "s/^VERSION=.*/VERSION=\"$VERSION\"/"  \
    -e 's/^MAINDIR=.*/MAINDIR=\"\@MAINDIR\"/' \
    -e 's/^MAINRC=.*/MAINRC=\"\$MAINDIR\/rc\"/' \
    -e 's/^STATDIR=.*/STATDIR=\"\@STATDIR\"/' \
    -e 's/^LOCK=.*/LOCK=\"@LOCKFILE\"/' \
    -e 's/^DEBUG=.*/DEBUG=/' $MAINDIR/$MAINPRG >tmp/newrottlog
if test ! -s tmp/newrottlog
then
	echo "ERROR EXECUTING SED!"
	echo "PLEASE CHECK WHAT HAPPENED!"
	exit 3
fi

# Update configure script to integrate declared variables,
# and prepare for build environment.
echo -n "configure.ac, "
sed -e s/\@VERSION/$VERSION/ \
    -e "s/AC_INIT.*/AC_INIT(rottlog,$VERSION,$MAIL)/" \
    configure.ac >tmp/configure.ac
if test ! -s tmp/configure.ac
then
	echo "ERROR EXECUTING SED!"
	echo "PLEASE CHECK WHAT HAPPENED!"
	exit 5
fi
cp tmp/configure.ac configure.ac
aclocal
automake -ac
autoconf
./configure

# Assemble package tree structure and integrate files.
mkdir -p tmp/$MAINPRG-$VERSION
mkdir -p tmp/$MAINPRG-$VERSION/src
mkdir -p tmp/$MAINPRG-$VERSION/rc
mkdir -p tmp/$MAINPRG-$VERSION/doc

cat -s FILES |grep -v  "^#"|while read i
do
	cp -rv ./$i tmp/$MAINPRG-$VERSION/$i
done
cp -v tmp/newrottlog tmp/$MAINPRG-$VERSION/src/rottlog
cp -v tmp/configure.ac tmp/$MAINPRG-$VERSION/configure.ac

# Get rid of Arch cruft.
echo "Press Enter to create tarball:"
read i
if test "$i" = ""
then
	cd tmp
	find $MAINPRG-$VERSION -name '{arch}' -type d -exec rm -Rf {} \;
fi

# Make the archive
tar cfvz ../tar/$MAINPRG-$VERSION.tar.gz $MAINPRG-$VERSION
if test $? -ne 0
then
	echo "An error occurred while assembling the tar ball."
	exit 2;
fi
rm -Rf $MAINPRG-$VERSION
cd ..

# Check for gpg2 (requires gpg-agent)
echo "Signing tarball with GnuPG."
if test -x /usr/bin/gpg
then
	gpg -b tar/$MAINPRG-$VERSION.tar.gz
	gpg --clearsign tar/$MAINPRG-$VERSION.tar.gz
elif test -x /usr/local/bin/gpg
then
	gpg -b tar/$MAINPRG-$VERSION.tar.gz
	gpg --clearsign tar/$MAINPRG-$VERSION.tar.gz
else
	gpg2 -b tar/$MAINPRG-$VERSION.tar.gz
	gpg2 --clearsign tar/$MAINPRG-$VERSION.tar.gz
fi

test ! -z "$1" && exit

