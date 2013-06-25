dnl This gets processed by m4.
dnl Macros:
dnl   PACKAGE_NAME
dnl   PACKAGE_VERSION
dnl   BINARY
dnl   BINARY_TARGET
dnl   CLIENT
dnl   SERVER

Name: PACKAGE_NAME
Version: PACKAGE_VERSION
Release: 1
License: Common Public Attribution License Version 1
Vendor: xTuple
URL: http://www.xtuple.com
Packager: xTuple Packaging <packaging@xtuple.com>
Requires: libgcc1`'dnl
ifelse(CLIENT, 1, `, libpq5, libqt4-core, libqt4-core, libqt4-designer, libqt4-gui, libqt4-help, libqt4-network, libqt4-script, libqt4-svg, libqt4-webkit, libqt4-xml, libqt4-xmlpatterns', `')`'dnl
ifelse(SERVER, 1, `, postgresql', `')

%description
xTuple is an ERP system.

%pre

%post

%preun

%postun

%clean

%files

