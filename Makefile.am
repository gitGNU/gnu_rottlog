# Rottlog Makefile
# Copyright 2003, 2004 Stefano Falsetto <falsetto@gnu.org>
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

bin_SCRIPTS = rottlog

info_TEXINFOS = ./doc/rottlog.texi
DIST_SUBDIRS = src rc doc

# Problems:
# - make clean do not remove .info files
# - make install do not install bin_SCRIPTS. At the moment I install it
#   in install-exec-hook

txz: all
	./SlackBuild root wheel

rottlog:
	@echo -n "Updating rottlog bash code... "
	@sed -e 's/^MAINDIR=.*/MAINDIR=\"$(esc_ETCDIR)\"/' \
	     -e 's/^STATDIR=.*/STATDIR=\"$(esc_STATDIR)\"/' \
	     -e 's/^BASE_TMP_DIR=.*/BASE_TMP_DIR=\"$(esc_TMPDIR)\"/' \
	     -e 's/^LOCK=.*/LOCK=\"$(esc_LOCKFILE)\"/' \
	     src/rottlog >newrottlog
	@if test -f newrottlog ; then \
	  echo "OK"; \
	  cp -f newrottlog src/rottlog; \
	else \
	  echo "ERROR!!"; \
	  exit 1; \
	fi
	@echo -n "Updating info pages... "
	@lista='$(info_TEXINFOS)'; for M in $$lista; do \
	  sed -e 's/\@\@ETCDIR/$(esc_ETCDIR)/' \
	      -e 's/\@\@STATDIR/\"$(esc_STATDIR)\"/' $$M > $$M.new; \
	  if test ! -s $$M.new ; then \
	    echo "ERROR"; \
	    exit 1; \
	  else \
	    mv $$M.new $$M; \
	  fi; \
	done; \
	echo "OK"

INSTALL_RC = ${INSTALL} -o ${LOG_OWN} -g ${LOG_GROUP} -m ${LOG_RC}
INSTALL_SCRIPT = ${INSTALL} -o ${LOG_OWN} -g ${LOG_GROUP} -m ${LOG_MODE}

install-data-local:
	mkdir -m $(ETC_MODE) -p $(ROTT_ETCDIR)
	mkdir -p $(ROTT_STATDIR)
	$(install_sh_DATA) $(srcdir)/rc/rc $(ROTT_ETCDIR)
	$(install_sh_DATA) $(srcdir)/rc/weekly $(ROTT_ETCDIR)

install-exec-hook:
	$(INSTALL_SCRIPT) $(srcdir)/src/rottlog $(bindir)/rottlog
