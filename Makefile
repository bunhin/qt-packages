.PHONY: all deb-src deb-src-control deb-bin-control deb-bin deb

PREFIX?=/usr
INT_PREFIX:=$(PREFIX)

openrpt/Makefile:
	cd openrpt && qmake ;

csvimp/Makefile: openrpt/bin/openrpt
	cd csvimp && qmake ;

qt-client/Makefile: csvimp/csvimp openrpt/bin/openrpt
	cd xtuple && qmake ;

openrpt/bin/openrpt: openrpt/Makefile
	cd openrpt && make ;

csvimp/csvimp: csvimp/Makefile openrpt/bin/openrpt
	cd csvimp && make ;

qt-client/bin/xtuple: qt-client/Makefile csvimp/csvimp openrpt/bin/openrpt
	cd xtuple && make ;

all: openrpt/bin/openrpt csvimp/csvimp qt-client/bin/xtuple

pkgstage:
	mkdir pkgstage ;

pkgstage/debian: pkgstage
	mkdir pkgstage/debian ;

debian:
	mkdir -p debian ;

install: $(DESTDIR)/$(PREFIX)/bin/xtuple.bin $(DESTDIR)/$(PREFIX)/bin/openrpt.bin $(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so $(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so

qt-client/widgets/libxtuplewidgets.so: qt-client/bin/xtuple
# This dependency is to redirect and to consolidate the generation function. libxtuplewidgets may in practice be a prerequisite for the xtuple binary.

$(DESTDIR)/$(PREFIX)/bin:
	mkdir -p $(DESTDIR)/$(PREFIX)/bin ;

$(DESTDIR)/$(PREFIX)/lib:
	mkdir -p $(DESTDIR)/$(PREFIX)/lib ;

$(DESTDIR)/$(PREFIX)/bin/xtuple.bin: $(DESTDIR)/$(PREFIX)/bin xtuple/bin/xtuple
	install -m 755 -T xtuple/bin/xtuple $(DESTDIR)/$(PREFIX)/bin/xtuple.bin ;

$(DESTDIR)/$(PREFIX)/bin/openrpt.bin: $(DESTDIR)/$(PREFIX)/bin openrpt/bin/openrpt
	install -m 755 -T openrpt/bin/openrpt $(DESTDIR)/$(PREFIX)/bin/openrpt.bin ;

$(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so: $(DESTDIR)/$(PREFIX)/lib widgets/libxtuplewidgets.so
	install -m 755 -T widgets/libxtuplewidgets.so $(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so

$(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so: $(DESTDIR)/$(PREFIX)/lib csvimp/plugins/libcsvimpplugin.so
	install -m 755 -T csvimp/plugins/libcsvimpplugin.so $(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so

$(DESTDIR)/$(PREFIX)/share/xtuple/XTupleGUIClient.qhc: qt-client/share/XTupleGUIClient.qhc

qt-client/share/XTupleGUIClient.qhc: xtuple/share/XTupleGUIClient.qhcp
	cd share && qcollectiongenerator -o XTupleGUIClient.qhc XTupleGUIClient.qhcp ;

qt-client/share/dict/welcome/wmsg.base.qm: xtuple/share/dict/welcome/wmsg.base.ts
	cd xtuple/share/dict/welcome ; lrelease *.ts ;

install-deb:
	$(MAKE) PREFIX=$(INT_PREFIX) DESTDIR=pkgstage/debian install ;

deb-bin-control: debian
	for file in packaging/debian/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(PACKAGE_VERSION)" -D "BINARY=1" -D "BINARY_TARGET=$(BINARY_TARGET)" -D "CLIENT=1" -D "SERVER=0" < "$file" > debian/"`basename "$file"`" ;
	for file in packaging/debian/cp/* ; do cp -pRP "$file" debian/"`basename "$file"`" ;

deb-src-control: debian
	for file in packaging/debian/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(PACKAGE_VERSION)" -D "BINARY=0" -D "CLIENT=1" -D "SERVER=0" < "$file" > debian/"`basename "$file"`" ;
	for file in packaging/debian/cp/* ; do cp -pRP "$file" debian/"`basename "$file"`" ;
	for file in packaging/debian/cp-src/* ; do cp -pRP "$file" debian/"`basename "$file"`" ;

deb-src: deb-src-control
	yes | debuild -S -sa ;

deb-bin: install-deb

deb: deb-bin

