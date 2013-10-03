dnl This gets processed by m4.
dnl Macros:
dnl   PACKAGE_NAME
dnl   PRODUCT_VERSION
dnl   PACKAGE_VERSION
dnl   BINARY
dnl   BINARY_TARGET
dnl   BUILD_CLIENT
dnl   BUILD_SERVER
dnl   BUILD_DATABASE
dnl
Name: PACKAGE_NAME
Version: PRODUCT_VERSION
Release: RELEASE_NUMBER
License: Common Public Attribution License Version 1
Vendor: xTuple
URL: http://www.xtuple.com
Packager: Package Maintainer <packaging@xtuple.com>
Summary: xTuple ERP
Source: SOURCE_NAME
Group: Applications/Databases
BuildRequires: m4, gcc, gcc-c++, zlib-devel, postgresql-devel, qt4-devel, qtwebkit-devel

%prep
%setup

%description
xTuple is an ERP system.

%package client
Requires: libgcc, libstdc++, zlib, postgresql-libs, qt, qt-x11, qt-postgresql, qtwebkit, xtuple-database = PRODUCT_VERSION
Summary: xTuple client

%description client
xTuple is an ERP system.

%pre client

%post client

%preun client

%postun client

%files client
%defattr(-,root,root)
%dir %attr(0755,root,root) PREFIX`'/lib/xtuple
%attr(0755,root,root) PREFIX`'/bin/xtuple
%attr(0755,root,root) PREFIX`'/lib/xtuple/xtuple
%attr(0755,root,root) PREFIX`'/lib/xtuple/xtuple.bin
%attr(0755,root,root) PREFIX`'/lib/xtuple/openrpt.bin
%attr(0755,root,root) PREFIX`'/lib/xtuple/xtuple-updater.bin
%attr(0755,root,root) PREFIX`'/lib/xtuple/libcsvimpplugin.so
%attr(0644,root,root) PREFIX`'/lib/xtuple/XTupleGUIClient.qhc
%attr(0644,root,root) PREFIX`'/lib/xtuple/English.aff
%attr(0644,root,root) PREFIX`'/lib/xtuple/English.dic
%dir %attr(0755,root,root) PREFIX`'/lib/xtuple/welcome
%attr(0644,root,root) PREFIX`'/lib/xtuple/welcome/*.qm

%package server
Requires: postgresql, postgresql-server, postgresql-contrib, xtuple-database = PRODUCT_VERSION
Summary: xTuple server

%description server
xTuple is an ERP system.

%pre server

%post server
echo "In order to configure the xTuple server automatically, run PREFIX`'/lib/xtuple/database_setup.sh when all installations complete." ;

%preun server

%postun server

%files server

%package database
Summary: xTuple database utilities

%description database
xTuple is an ERP system.

%pre database

%post database

%preun database

%postun database

%files database
%attr(0755,root,root) PREFIX`'/lib/xtuple/database_setup.sh
%attr(0644,root,root) PREFIX`'/lib/xtuple/init.sql
%attr(0644,root,root) PREFIX`'/lib/xtuple/postbooks_quickstart.backup

%clean
make clean ;

%install
make install CLIENT=1 SERVER=0 DATABASE=0 DESTDIR="$RPM_BUILD_ROOT" ;
make install CLIENT=0 SERVER=1 DATABASE=0 DESTDIR="$RPM_BUILD_ROOT" ;
make install CLIENT=0 SERVER=0 DATABASE=1 DESTDIR="$RPM_BUILD_ROOT" ;

