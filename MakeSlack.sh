#!/bin/bash
# Slackware distribution script
# Copyright (c) 2003, 2004 Stefano Falsetto <falsetto@gnu.org>
# Copyright (c) 2008 D E Evans <sinuhe@gnu.org>
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


if [ "$(whoami)" != "root" ]; then
  echo "You must be root!"
  exit
fi

if [ $# -lt 2 ]; then
  echo "Must be specified owner and group!"
  exit
else
  OWNER="$1"
  GROUP="$2"
fi

. ./VERSION

PRG="src/rottlog src/virottrc"
DOC="COPYING AUTHORS NEWS ChangeLog README INSTALL TODO VERSION"
MANUALS="$(cat FILES|grep "^man/"|grep -v "texinfo"|cut -d'/' -f2|while read a; do echo -n "$a "; done)"
MANSECTS="$(cat FILES|grep "^man/"|grep -v "texinfo"|cut -d'/' -f2|cut -d'.' -f2|sort|uniq|tr '\n' ' ')"
SROOT="tmp/Slackware"
PROGRAM="rottlog-$VERSION"
PRJDIR="$PWD/tar/Slackware"

rm -Rf "$SROOT"

echo "Making Slackware package..."
mkdir -p $PRJDIR
mkdir -p $SROOT/etc/rottlog
chown root.root $SROOT/etc/rottlog
chmod 0700 $SROOT/etc/rottlog

mkdir -p $SROOT/usr/doc/$PROGRAM
mkdir $SROOT/usr/sbin
mkdir -p $SROOT/var/run/rottlog
chown root.root $SROOT/var/run/rottlog
chmod 0700 $SROOT/var/run/rottlog
mkdir -p $SROOT/usr/info

for sect in $MANSECTS; do
  mkdir -p $SROOT/usr/man/man${sect}
  for i in man/*.$sect; do
    bi=$(basename $i)
    if [ $(expr "$MANUALS" : ".*$bi.*") -ne 0 ]; then
      cp man/$bi $SROOT/usr/man/man${sect}
    fi
  done
done

cp $PRG $SROOT/usr/sbin
cp $DOC $SROOT/usr/doc/$PROGRAM

for INFOFILE in ./man/texinfo/*.info; do
  cp $INFOFILE $SROOT/usr/info
done

for i in rottlog virottrc; do
  chmod 500 $SROOT/usr/sbin/$i
  chown root.root $SROOT/usr/sbin/$i
done

for p in month week day custom; do
  ln -s virottrc $SROOT/usr/sbin/virott${p}
done

mkdir -p $SROOT/install
cat <<EOF >$SROOT/install/description
PACKAGE DESCRIPTION:

rottlog: This is GNU Rot[t]Log v.$VERSION
rottlog: 
rottlog: archive, rotates, compresses, and mails system logs.
rottlog: 
rottlog: This is a replacement to Red Hat's logrotate. It have similar
rottlog: syntax, but more powerful features to cut and store logs. 
rottlog: It's all written in BASH (2.x compatible).
rottlog: 
rottlog:
EOF

cat <<EOF >$SROOT/install/doinst.sh
echo
cat install/description

sed '/PACKAGE LOCATION/r /install/description' < /var/log/packages/$PROGRAM >description.tmp
mv description.tmp /var/log/packages/$PROGRAM
rm install/description

EOF

cd $SROOT
makepkg -l y $PROGRAM.tgz
if [ $? -ne 0 ]; then
  echo "An error occurred during package creation!"
  exit 1;
fi
chown $OWNER.$GROUP $PROGRAM.tgz
mv $PROGRAM.tgz $PRJDIR
cd -
rm -Rf $SROOT
echo "Slackware package creation finished."

