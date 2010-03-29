# Rot[t]Log installation defaults
# Copyright 2002, 2003 Stefano Falsetto <falsetto@gnu.org>
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

# Edit this file to fits your needs

# Basedir to install rottlog and log2rot
# Must be an absolute dirname used in LOG_OWN's PATH environnment
BINDIR="/usr/sbin"

# Basedir to install documentation dir
# Must be an absolute dirname
DOCDIR="/usr/share/doc"

# Basedir to install man pages
# Must be an absolute dirname
MANDIR="/usr/share/man"

# Set to 1 to compress with gzip man pages
# Set to 0 to NOT to compress man pages
MANGZIP=1

# Owner of installed codes
LOG_OWN="root"

# Group of installed codes
LOG_GROUP="root"

# Permissions of rottlog and log2rot
LOG_MODE=0500

# Directory to store configuration files
# Must be an absolute dirname
ROTT_ETCDIR="/etc/rottlog"

# Default permissions of ROTT_ETCDIR dir
ETC_MODE=0300

# Directory to store status files
# Must be an absolute existent directory
ROTT_STATDIR="/var/lib/rottlog"

# Default permissions of ROTT_STATDIR dir
STAT_MODE=0700

