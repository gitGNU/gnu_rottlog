# RPM spec file for GNU Rot[t]log
# See the end of the file for license conditions.

%define _bindir      /usr/bin
%define _docdir      /usr/share/doc
%define packer %(finger -lp `echo "$USER"` | head -n 1 | cut -d: -f 3)

Name: emacs
Summary: GNU rottlog is the GNU log management utility.
Version: 0.71.2
Release: 1
License: GPLv3+
Vendor: Free Software Foundation
Packager: %packer
URL: http://www.gnu.org/software/rottlog/
Group: Applications/System
Source: http://ftp.gnu.org/gnu/rottlog/rottlog-%{version}.tar.gz
Buildroot: %{_tmppath}/%{name}-root
BuildRequires: autoconf, automake, texinfo

%description
GNU rottlog is the GNU log management utility.  It is designed
to simplify administration of systems that generate large numbers of
log files.  It allows automatic rotation, compression, and archiving of
logs.  It also mails reports to the system administrator.  Each log file
may be handled daily, weekly, monthly, in user-defined days, or when it
becomes too large.

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
%doc AUTHORS ChangeLog COPYING* INSTALL NEWS README* TODO
%{_bindir}/*
%{_mandir}/*/*
%{_infodir}/*

%changelog
* Mon Dec 27 2009 D. E. Evans <sinuhe@gnu.org>
- Initial release.

#This file is an addition to GNU Emacs.
# Copyright 2009 D. E. Evans <sinuhe@gnu.org>
#
#The GNU Emacs spec file is free software: you can redistribute
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
#along with the GNU Emacs spec file.  If not, see
#<http://www.gnu.org/licenses/>.
