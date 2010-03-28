# RPM spec file for GNU Rot[t]log
# See the end of the file for license conditions.

%define _bindir      /usr/sbin
%define _docdir      /usr/share/doc
%define packer %(finger -lp `echo "$USER"` | head -n 1 | cut -d: -f 3)

Name: rottlog
Summary: GNU rottlog is the GNU log management utility.
Version: 0.72.2
Release: 1
License: GPLv3+
Vendor: Free Software Foundation
Packager: %packer
URL: http://www.gnu.org/software/rottlog/
Group: Applications/System
Source: http://ftp.gnu.org/gnu/rottlog/rottlog-%{version}.tar.gz
Buildroot: %{_tmppath}/%{name}-root
BuildArch: noarch
BuildRequires: autoconf, automake, texinfo

%description
GNU rottlog is the GNU log management utility.  It is designed to
simplify administration of systems that generate large numbers
of log files.  It archives and compresses logs.  It also mails
reports to the system administrator.  Each log file may be handled
daily, weekly, monthly, in user-defined days, or when it becomes
too large.

%prep
echo Building %{name}-%{version}-%{release}
%setup -q -n %{name}-%{version}
%configure

%build
%{__make}

%install
%__rm -rf %{buildroot}
%makeinstall
%__rm -f %{buildroot}%{_infodir}/dir

%post
for a in %{info_files}; do
  /sbin/install-info %{_infodir}/$a %{_infodir}/dir 2> /dev/null || :
done

%preun
if [ "$1" = 0 ]; then
  for b in %{info_files}; do
    /sbin/install-info --delete %{_infodir}/$b %{_infodir}/dir 2> /dev/null || :
  done
fi

%clean
%__rm -rf %{buildroot}

%files
%defattr(-,root,root)
%doc AUTHORS ChangeLog COPYING* INSTALL LOG2ROT NEWS README TODO
%{_bindir}/*
%{_infodir}/*

%changelog
* Fri Mar 28 2010 D. E. Evans <sinuhe@gnu.org>
- Release 0.72.2

* Fri Mar 23 2010 D. E. Evans <sinuhe@gnu.org>
- Add log2rot doc.

* Fri Mar 20 2010 D. E. Evans <sinuhe@gnu.org>
- Install to sbin, not bin.
- Toggle release for 0.72.1.

* Fri Mar 19 2010 D. E. Evans <sinuhe@gnu.org>
- Release 0.72.

* Mon Dec 27 2009 D. E. Evans <sinuhe@gnu.org>
- Initial release.

#This file is part GNU Rot[t]log.
# Copyright 2009, 2010 D. E. Evans <sinuhe@gnu.org>
#
#The GNU Rot[t]log spec file is free software: you can redistribute
#it and/or modify it under the terms of the GNU General Public
#License as published by the Free Software Foundation, either
#version 3 of the License, or (at your option) any later version.
#
#The spec file is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with the GNU Rot[t]log spec file.  If not, see
#<http://www.gnu.org/licenses/>.
