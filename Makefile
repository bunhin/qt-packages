.PHONY: all deb-src deb-src-control deb-bin-control deb-bin deb clean install install-deb

PREFIX?=/usr
INT_PREFIX:=$(PREFIX)

DEB_VERSION_TRAILER:=
ifneq ($(UBUNTU_RELEASE),)
DEB_VERSION_TRAILER:=0ubuntu1~$(UBUNTU_RELEASE)
DEB_OS_RELEASE:=$(UBUNTU_RELEASE)
endif
PRODUCT_NAME:=xtuple
PACKAGE_NAME:=$(PRODUCT_NAME)
PRODUCT_VERSION:=$(shell cat qt-client/guiclient/version.cpp | awk '/^QString _Version/ { printf "%s" , $$4 ; }' | sed -e 's/^\"//g' -e 's/\";\?$$//g')
ifneq ($(PACKAGE_TRAILER),)
PACKAGE_VERSION:=$(PRODUCT_VERSION)-$(PACKAGE_TRAILER)
else
PACKAGE_VERSION:=$(PRODUCT_VERSION)
endif
DEB_PACKAGE_VERSION:=$(PACKAGE_VERSION)-$(DEB_VERSION_TRAILER)
CHANGELOG_TIME:=$(shell date "+%a, %d %b %Y %H:%M:%S")
CHANGELOG_TIMESTAMP:=$(CHANGELOG_TIME) -0500
PACKAGER_NAME:=Package Maintainer
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
	cd qt-client && ( for dir in openrpt csvimp xtlib ; do if [ -e "$$dir" ] && [ ! -e "$$dir"/* ] ; then rmdir "$$dir" ; fi ; done ; ) && qmake ;

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

ifeq ($(CLIENT),0)
ifeq ($(SERVER),1)
install:
else
install:
endif
else
install: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple.bin $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/openrpt.bin $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple-updater.bin $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/libcsvimpplugin.so $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/XTupleGUIClient.qhc $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.aff $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.dic $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome/wmsg.base.qm $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple $(DESTDIR)/$(INT_PREFIX)/bin/xtuple
endif

$(DESTDIR)/$(INT_PREFIX)/bin:
	mkdir -p $(DESTDIR)/$(INT_PREFIX)/bin ;

$(DESTDIR)/$(INT_PREFIX)/lib:
	mkdir -p $(DESTDIR)/$(INT_PREFIX)/lib ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple qt-client/xtuple
	install -m 755 -T qt-client/xtuple $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple ;

$(DESTDIR)/$(INT_PREFIX)/bin/xtuple: $(DESTDIR)/$(INT_PREFIX)/bin
	cd $(DESTDIR)/$(INT_PREFIX)/bin ; ln -s ../lib/xtuple/xtuple xtuple ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple:
	mkdir -p $(DESTDIR)/$(INT_PREFIX)/lib/xtuple ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome:
	mkdir -p $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple.bin: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple qt-client/bin/xtuple
	install -m 755 -T qt-client/bin/xtuple $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple.bin ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/openrpt.bin: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple openrpt/bin/openrpt
	install -m 755 -T openrpt/bin/openrpt $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/openrpt.bin ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple-updater.bin: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple updater/bin/updater
	install -m 755 -T updater/bin/updater $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/xtuple-updater.bin ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/libxtuplewidgets.so: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple qt-client/widgets/libxtuplewidgets.so
	install -m 755 -T qt-client/widgets/libxtuplewidgets.so $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/libxtuplewidgets.so ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/libcsvimpplugin.so: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple csvimp/plugins/libcsvimpplugin.so
	install -m 755 -T csvimp/plugins/libcsvimpplugin.so $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/libcsvimpplugin.so ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/XTupleGUIClient.qhc: qt-client/share/XTupleGUIClient.qhc
	install -m 644 -T qt-client/share/XTupleGUIClient.qhc $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/XTupleGUIClient.qhc ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.aff: qt-client/hunspell/English.aff
	install -m 644 -T qt-client/hunspell/English.aff $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.aff ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.dic: qt-client/hunspell/English.dic
	install -m 644 -T qt-client/hunspell/English.dic $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/English.dic ;

$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome/wmsg.base.qm: $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome qt-client/share/dict/welcome/wmsg.base.qm ;
	cd qt-client/share/dict/welcome && for file in *.qm ; do if [ "`echo "$(DESTDIR)" | grep '^\/'`" != "" ] ; then install -m 644 -T "$$file" $(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome/"$$file" ; else install -m 644 -T "$$file" ../../../../$(DESTDIR)/$(INT_PREFIX)/lib/xtuple/welcome/"$$file" ; fi ; done ;

qt-client/share/XTupleGUIClient.qhc: qt-client/share/XTupleGUIClient.qhcp
	cd qt-client/share && qcollectiongenerator -o XTupleGUIClient.qhc XTupleGUIClient.qhcp ;

qt-client/share/dict/welcome/wmsg.base.qm: qt-client/share/dict/welcome/wmsg.base.ts
	cd qt-client/share/dict/welcome ; lrelease *.ts ;

$(DEB_CHANGELOG_FILE): debian qt-client/guiclient/version.cpp
	echo "$(PRODUCT_NAME)"" (""$(DEB_PACKAGE_VERSION)"") ""$(DEB_OS_RELEASE)""; urgency=low" > "$(DEB_CHANGELOG_FILE)" ;
	echo "" >> "$(DEB_CHANGELOG_FILE)" ;
	echo "  * Release." >> "$(DEB_CHANGELOG_FILE)" ;
	echo "" >> "$(DEB_CHANGELOG_FILE)" ;
	echo " -- ""$(PACKAGER_NAME)"" <""$(PACKAGER_MAIL)"">  ""$(CHANGELOG_TIMESTAMP)" >> "$(DEB_CHANGELOG_FILE)" ;

deb-src-control: debian $(DEB_CHANGELOG_FILE)
	for file in packaging/debian/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(DEB_PACKAGE_VERSION)" -D "BINARY=0" -D "CLIENT=1" -D "SERVER=0" -D "PREFIX=$(PREFIX)" < "$$file" > debian/"`basename "$$file"`" ; done ;
	for file in packaging/debian/cp/* ; do cp -pRP "$$file" debian/"`basename "$$file"`" ; done ;
	for file in packaging/debian/cp-src/* ; do cp -pRP "$$file" debian/"`basename "$$file"`" ; done ;

deb-src: deb-src-control
	yes | debuild -S -sa ;

deb:
	yes | debuild ;

rpm-src-control:
	mkdir -p redhat ;
	for file in packaging/redhat/m4/* ; do m4 -D "PACKAGE_NAME=$(PACKAGE_NAME)" -D "PACKAGE_VERSION=$(PACKAGE_VERSION)" -D "BINARY=0" -D "CLIENT=1" -D "SERVER=0" -D "PREFIX=$(PREFIX)" < "$$file" > redhat/"`basename "$$file"`" ; done ;

rpm-src:
	cd .. ; cp -pRP qt-packages/redhat/*.spec ./ ; cp -pRP qt-packages $(PACKAGE_NAME)-$(PACKAGE_VERSION) ; tar -czf $(PACKAGE_NAME)-$(PACKAGE_VERSION).tar.gz $(PACKAGE_NAME)-$(PACKAGE_VERSION) ;

