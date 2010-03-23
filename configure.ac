#                                               -*- Autoconf -*-
# Autoconf script for rottlog.
# Copyright 2003 Stefano Falsetto <falsetto@gnu.org>
# Copyright 2008, 2009, 2010 David Egan Evans <sinuhe@gnu.org>
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

AC_PREREQ(2.57)
AC_INIT(rottlog,0.72.2,[sinuhe@gnu.org])
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/rottlog])

AC_CANONICAL_HOST

#AC_MSG_NOTICE([L'host canonical è $host_cpu-$host_vendor, $host_os])

# Add config options
AC_SUBST(MANGZIP,1)
AC_ARG_ENABLE(mangzip,
	AC_HELP_STRING([--enable-mangzip],
	  [Don't gzip man pages (default yes)]),
	[ case "$enableval" in
	    yes) AC_SUBST(MANGZIP,1) ;;
	    no)  AC_SUBST(MANGZIP,0) ;;
	    *) AC_MSG_ERROR(bad value $enableval for --enable-mangzip) ;;
	  esac])

AC_ARG_VAR(LOG_OWN,[Owner for rottlog binary (default root)])
AC_ARG_VAR(LOG_GROUP,[Group for rottlog binary (default root)])
AC_ARG_VAR(ROTT_ETCDIR,[Configuration directory (default /etc/rottlog)])
AC_ARG_VAR(LOCKFILE,[Lock file (default /var/lock/LOCK.rottlog)])
if test "x$LOG_OWN" = "x"
then
  AC_SUBST(LOG_OWN,root)
fi
if test "x$LOG_GROUP" = "x"
then
  AC_SUBST(LOG_GROUP,root)
fi
if test "x$ROTT_ETCDIR" = "x"
then
  AC_SUBST(ROTT_ETCDIR,/etc/rottlog)
fi
AC_MSG_CHECKING([for lock directory])
if test "x$LOCKFILE" = "x"
then
  if test -d /var/spool/lock
  then
    AC_SUBST(LOCKFILE,/var/spool/lock/LOCK.rottlog)
  fi
  if test -d /var/lock
  then
    AC_SUBST(LOCKFILE,/var/lock/LOCK.rottlog)
  fi
  #AC_SUBST(LOCKFILE,/var/lock/LOCK.rottlog)
  if test "x$LOCKFILE" = "x"
  then
    AC_SUBST(LOCKFILE,/tmp/LOCK.rottlog)
  fi
fi
AC_MSG_RESULT([$LOCKFILE])
  
AC_PATH_PROGS(PRGDATE,		date)
if test "x${PRGDATE}" = "x"
then
  AC_MSG_ERROR([Can't continue without date!])
else
  my_test_date=$(date --date "+1 day" 1>/dev/null 2>/dev/null; echo $?)
fi

# TODO: Add O.S. recognition and programs finding
# $host_cpu=i686
# $host_vendor=pc
# $host_os=linux-gnu
#case $host_os in
#  linux*)
#        ;;
#  *BSD)
#        ;;
#  *)
#        ;;
#esac

# Checks for programs.
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_EGREP
AC_PROG_LN_S

AC_PATH_PROGS(MAKEINFO,		makeinfo)
if test "x${MAKEINFO}" = "x" 
then
  AC_MSG_ERROR([Please install Texinfo.])
fi
AC_PATH_PROGS(MV,		mv)
AC_PATH_PROGS(SED,		sed)

AC_CHECK_PROGS(FIND,		find)
if test "x${FIND}" = "x"
then
  AC_MSG_ERROR([Can't use find program. Please install it.])
fi

AC_CHECK_PROGS(CHMOD,		chmod)
AC_CHECK_PROGS(CAL,		cal)
if test "x${CAL}" = "x" 
then
  AC_MSG_ERROR([Can't use cal program. Please install it.])
fi
AC_CHECK_PROGS(MIMENCODE,	mimencode)
if test "x${MIMENCODE}" = "x"
then
  AC_MSG_WARN([Can't attach mimencoded logs in email.])
fi

AC_SUBST(bindir,${prefix}/sbin)
AC_SUBST(datadir,[])

#AC_SUBST(MANDIR,${prefix}/man)
AC_SUBST(LOG_MODE,0500)
AC_SUBST(ETC_MODE,0300)
AC_SUBST(ROTT_STATDIR,/var/lib/rottlog)
AC_SUBST(STAT_MODE,0700)

AC_MSG_CHECKING([for documentation directory])
for docdir in /usr/doc /usr/share/doc /var/share/doc /var/doc
do
  if test -d "$docdir"
  then
    AC_SUBST(DOCDIR,$docdir)
    break
  fi
done
AC_MSG_RESULT([$docdir])

AC_MSG_CHECKING([for temporary directory])
for tmpdir in /tmp /var/tmp
do
  if test -d "$tmpdir"
  then
    AC_SUBST(BASE_TMP_DIR,$tmpdir)
    break
  fi
done
AC_MSG_RESULT([$tmpdir])


AC_CHECK_PROGS(GZIP,		gzip)
if test "x$GZIP" = "x"  
then
  AC_MSG_WARN([Can't find gzip.])
  AC_MSG_CHECKING([for bzip2])
  AC_CHECK_PROGS(BZIP2,bzip2)
  if test "x$BZIP2" = "x"  
  then
    AC_MSG_WARN([Can't find bzip2.])
    AC_MSG_CHECKING([for compress])
    AC_CHECK_PROGS(COMPRESS,compress)
    if test "x$COMPRESS" = "x"  
    then
      AC_MSG_ERROR([Can't find any compressor program. Please install either gzip or bzip2, or compress])
    fi
    AC_CHECK_PROGS(UNCOMPRESS,uncompress)
    if test "x$UNCOMPRESS" = "x"  
    then
      AC_MSG_ERROR([Can't find uncompress. Can't use any compressor program.])
    fi
  fi
  AC_CHECK_PROGS(BUNZIP2,bunzip2)
  if test "x$BUNZIP2" = "x"  
  then
    AC_MSG_WARN([Strange... Can't find bunzip2...])
    AC_SUBST(BUNZIP2,[$BZIP2 -d])
  fi
fi
AC_CHECK_PROGS(GUNZIP,		gunzip)
if test "x$GUNZIP" = "x"  
then
  AC_MSG_WARN([Strange... Can't find gunzip...])
  AC_SUBST(GUNZIP,[$GZIP -d])
fi

AC_MSG_NOTICE([Escaping variables due to sed weakness...])
esc_ETCDIR="${ROTT_ETCDIR//\//\\/}"
esc_STATDIR="${ROTT_STATDIR//\//\\/}"
esc_TMPDIR="${BASE_TMP_DIR//\//\\/}"
esc_LOCKFILE="${LOCKFILE//\//\\/}"
AC_SUBST(esc_ETCDIR,[$esc_ETCDIR])
AC_SUBST(esc_STATDIR,[$esc_STATDIR])
AC_SUBST(esc_TMPDIR,[$esc_TMPDIR])
AC_SUBST(esc_LOCKFILE,[$esc_LOCKFILE])

# Checks for library functions.
AC_OUTPUT([Makefile],
	chmod 444 Makefile
)
