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

%package client
Requires: libgcc1, libpq5, libqt4-core, libqt4-core, libqt4-designer, libqt4-gui, libqt4-help, libqt4-network, libqt4-script, libqt4-svg, libqt4-webkit, libqt4-xml, libqt4-xmlpatterns

%description client
xTuple is an ERP system.

%pre client

%post client

%preun client

%postun client

%clean client

%files client
%defattr(-,root,root)
%dir %attr(0755,root,root) PREFIX`'/lib/xtuple
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
Requires: postgresql

%description server
xTuple is an ERP system.

%pre server

%post server

%preun server

%postun server

%clean server

%files server

