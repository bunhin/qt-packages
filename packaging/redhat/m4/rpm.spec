dnl This gets processed by m4.
dnl Macros:
dnl   PACKAGE_NAME
dnl   PRODUCT_VERSION
dnl   PACKAGE_VERSION
dnl   BINARY
dnl   BINARY_TARGET
dnl   CLIENT
dnl   SERVER

Name: PACKAGE_NAME
Version: PRODUCT_VERSION
Release: RELEASE_NUMBER
License: Common Public Attribution License Version 1
Vendor: xTuple
URL: http://www.xtuple.com
Packager: Package Maintainer <packaging@xtuple.com>
Summary: xTuple ERP
Source: PACKAGE_NAME`'-`'PACKAGE_VERSION

%prep
%setup

%description
xTuple is an ERP system.

%package client
Requires: libgcc1, libpq5, libqt4-core, libqt4-core, libqt4-designer, libqt4-gui, libqt4-help, libqt4-network, libqt4-script, libqt4-svg, libqt4-webkit, libqt4-xml, libqt4-xmlpatterns, libqt4-sql-psql, xtuple-database
Summary: xTuple client

%description client
xTuple is an ERP system.

%install client
make install CLIENT=1 SERVER=0 DATABASE=0 DESTDIR="$RPM_BUILD_ROOT" ;

%pre client

%post client

%preun client

%postun client

%clean client

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
Requires: postgresql postgresql-contrib xtuple-database
Summary: xTuple server

%description server
xTuple is an ERP system.

%install server
make install CLIENT=0 SERVER=1 DATABASE=0 DESTDIR="$RPM_BUILD_ROOT" ;

%pre server

%post server
echo "In order to configure the xTuple server automatically, run PREFIX`'/lib/xtuple/database_setup.sh when all installations complete." ;

%preun server

%postun server

%clean server

%files server

%package database
Requires: 
Summary: xTuple database utilities

%description database
xTuple is an ERP system.

%install database
make install CLIENT=0 SERVER=0 DATABASE=1 DESTDIR="$RPM_BUILD_ROOT" ;

%pre database

%post database

%preun database

%postun database

%clean database

%files database
%attr(0755,root,root) PREFIX`'/lib/xtuple/database_setup.sh
%attr(0644,root,root) PREFIX`'/lib/xtuple/init.sql
%attr(0644,root,root) PREFIX`'/lib/xtuple/postbooks_quickstart.backup

