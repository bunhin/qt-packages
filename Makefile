.PHONY: all deb-src deb-src-control deb-bin-control deb-bin deb clean

PREFIX?=/usr
INT_PREFIX:=$(PREFIX)

DEB_VERSION_TRAILER:=
ifneq ($(UBUNTU_RELEASE),)
DEB_VERSION_TRAILER:=0ubuntu1~$(UBUNTU_RELEASE)
DEB_OS_RELEASE:=$(UBUNTU_RELEASE)
endif
PRODUCT_NAME:=xtuple-client
PACKAGE_NAME:=$(PRODUCT_NAME)
PRODUCT_VERSION:=$(shell cat qt-client/guiclient/version.cpp | awk '/^QString _Version/ { printf "%s" , $$4 ; }' | sed -e 's/^\"//g' -e 's/\";\?$$//g')
DEB_PACKAGE_VERSION:=$(PRODUCT_VERSION)-$(DEB_VERSION_TRAILER)
CHANGELOG_TIME:=$(shell date "+%a, %d %b %Y %H:%M:%S")
CHANGELOG_TIMESTAMP:=$(CHANGELOG_TIME) -500
PACKAGER_NAME:=xTuple Packaging
PACKAGER_MAIL:=packaging@xtuple.com

DEB_CHANGELOG_FILE=debian/changelog

all: openrpt/bin/openrpt csvimp/csvimp qt-client/bin/xtuple updater/bin/updater

clean:
	cd openrpt && make clean || echo No Makefile. ;
	cd csvimp && make clean || echo No Makefile. ;
	cd qt-client && make clean || echo No Makefile. ;
	cd updater && make clean || echo No Makefile. ;

openrpt/Makefile:
	cd openrpt && qmake ;

csvimp/Makefile: openrpt/bin/openrpt
	cd csvimp && qmake ;

qt-client/Makefile: csvimp/csvimp openrpt/bin/openrpt
	cd qt-client && qmake ;

updater/Makefile: openrpt/bin/openrpt qt-client/bin/xtuple
	cd updater && qmake ;

openrpt/bin/openrpt: openrpt/Makefile
	cd openrpt && make ;

csvimp/csvimp: csvimp/Makefile openrpt/bin/openrpt
	cd csvimp && make ;

qt-client/bin/xtuple: qt-client/Makefile csvimp/csvimp openrpt/bin/openrpt
	cd qt-client && make ;

updater/bin/updater: updater/Makefile openrpt/bin/openrpt qt-client/bin/xtuple
	cd updater && make ;

pkgstage:
	mkdir pkgstage ;

pkgstage/debian: pkgstage
	mkdir pkgstage/debian ;

debian:
	mkdir -p debian ;

install: $(DESTDIR)/$(PREFIX)/bin/xtuple.bin $(DESTDIR)/$(PREFIX)/bin/openrpt.bin $(DESTDIR)/$(PREFIX)/bin/xtuple-updater.bin $(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so $(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so

qt-client/widgets/libxtuplewidgets.so: qt-client/bin/xtuple
# This dependency is to redirect and to consolidate the generation function. libxtuplewidgets may in practice be a prerequisite for the xtuple binary.

$(DESTDIR)/$(PREFIX)/bin:
	mkdir -p $(DESTDIR)/$(PREFIX)/bin ;

$(DESTDIR)/$(PREFIX)/lib:
	mkdir -p $(DESTDIR)/$(PREFIX)/lib ;

$(DESTDIR)/$(PREFIX)/bin/xtuple.bin: $(DESTDIR)/$(PREFIX)/bin qt-client/bin/xtuple
	install -m 755 -T qt-client/bin/xtuple $(DESTDIR)/$(PREFIX)/bin/xtuple.bin ;

$(DESTDIR)/$(PREFIX)/bin/openrpt.bin: $(DESTDIR)/$(PREFIX)/bin openrpt/bin/openrpt
	install -m 755 -T openrpt/bin/openrpt $(DESTDIR)/$(PREFIX)/bin/openrpt.bin ;

$(DESTDIR)/$(PREFIX)/bin/xtuple-updater.bin: $(DESTDIR)/$(PREFIX)/bin updater/bin/updater
	install -m 755 -T updater/bin/updater $(DESTDIR)/$(PREFIX)/bin/xtuple-updater.bin ;

$(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so: $(DESTDIR)/$(PREFIX)/lib qt-client/widgets/libxtuplewidgets.so
	install -m 755 -T qt-client/widgets/libxtuplewidgets.so $(DESTDIR)/$(PREFIX)/lib/libxtuplewidgets.so

$(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so: $(DESTDIR)/$(PREFIX)/lib csvimp/plugins/libcsvimpplugin.so
	install -m 755 -T csvimp/plugins/libcsvimpplugin.so $(DESTDIR)/$(PREFIX)/lib/libcsvimpplugin.so

$(DESTDIR)/$(PREFIX)/share/xtuple/XTupleGUIClient.qhc: qt-client/share/XTupleGUIClient.qhc

qt-client/share/XTupleGUIClient.qhc: qt-client/share/XTupleGUIClient.qhcp
	cd qt-client/share && qcollectiongenerator -o XTupleGUIClient.qhc XTupleGUIClient.qhcp ;

qt-client/share/dict/welcome/wmsg.base.qm: qt-client/share/dict/welcome/wmsg.base.ts
	cd qt-client/share/dict/welcome ; lrelease *.ts ;

install-deb:
	$(MAKE) PREFIX=$(INT_PREFIX) DESTDIR=pkgstage/debian install ;

$(DEB_CHANGELOG_FILE): debian qt-client/guiclient/version.cpp
	echo "$(PRODUCT_NAME)"" (""$(DEB_PACKAGE_VERSION)"") ""$(DEB_OS_RELEASE)""; urgency=low" > "$(DEB_CHANGELOG_FILE)" ;
	echo "" >> "$(DEB_CHANGELOG_FILE)" ;
	echo "  * Release." >> "$(DEB_CHANGELOG_FILE)" ;
	echo "" >> "$(DEB_CHANGELOG_FILE)" ;
	echo " -- ""$(PACKAGER_NAME)"" <""$(PACKAGER_MAIL)"">  ""$(CHANGELOG_TIMESTAMP)" >> "$(DEB_CHANGELOG_FILE)" ;

deb-bin-control: debian $(DEB_CHANGELOG_FILE)
	for file in packaging/debian/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(DEB_PACKAGE_VERSION)" -D "BINARY=1" -D "BINARY_TARGET=$(BINARY_TARGET)" -D "CLIENT=1" -D "SERVER=0" < "$$file" > debian/"`basename "$$file"`" ; done ;
	for file in packaging/debian/cp/* ; do cp -pRP "$file" debian/"`basename "$$file"`" ; done ;

deb-src-control: debian $(DEB_CHANGELOG_FILE)
	for file in packaging/debian/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(DEB_PACKAGE_VERSION)" -D "BINARY=0" -D "CLIENT=1" -D "SERVER=0" < "$$file" > debian/"`basename "$$file"`" ; done ;
	for file in packaging/debian/cp/* ; do cp -pRP "$$file" debian/"`basename "$$file"`" ; done ;
	for file in packaging/debian/cp-src/* ; do cp -pRP "$$file" debian/"`basename "$$file"`" ; done ;

deb-src: deb-src-control
	yes | debuild -S -sa ;

deb-bin: install-deb

deb: deb-bin

	
