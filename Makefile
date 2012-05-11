.PHONY: all help usage conf pkg var masterconf
SHELL           = /bin/bash
DATE		= `date +%y%m%d`

define HELP
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
  PGWS - Postgresql WebServices.

  Install into upper dir:
    make install

  Check if all requirements are satisfied:
    make test

  Drop DB objects and any generated files:
    make uninstall

endef
export HELP


help:
	@echo "$$HELP"

all: help
usage: help

install: test conf pkg var masterconf installcomplete

installapp: test conf-app pkg-app var masterconf installcomplete

conf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; [ -d conf ] || mkdir conf ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in conf/*.{json,conf} ; do [ -f $$root/$$p ] || ln -s  ${PWD}/ws/eg/$$p $$root/$$p ; done ; \
popd > /dev/null

conf-app:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; [ -d conf ] || mkdir conf ; root=$$PWD ; \
pushd pkg/app/eg > /dev/null ; \
for p in conf/*.json ; do [ -f $$root/$$p ] || ln -s $$root/pkg/app/eg/$$p $$root/$$p ; done ; \
popd > /dev/null ; popd > /dev/null

pkg:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; [ -d pkg ] || mkdir pkg ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in pkg/* ; do [ -e $$root/$$p ] || ln -s $$PWD/$$p $$root/$$p ; done ; \
popd > /dev/null

pkg-app:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; root=$$PWD ; . pgws.cfg ; \
for p in $$PGWS_APP_PKG ; do [ -e $$root/pkg/$$p ] || ln -s $$root/pgws/ws/eg/pkg/$$p pkg/$$p ; done ; \
popd > /dev/null

var:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -d var ] || mkdir var ; \
for p in build cache log run tmpl tmpc ; do [ -d var/$$p ] || mkdir -m g+w var/$$p ; done ; \
popd > /dev/null

masterconf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f pgws.cfg ] || ln ${PWD}/ws/eg/pgws.cfg pgws.cfg ; \
[ -f pgws.sh ] || ln ${PWD}/ws/eg/pgws.sh pgws.sh ; \
popd > /dev/null

gitignore:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f .gitignore ] || touch .gitignore ; \
for p in pgws var conf  ; do grep -E "^$$p" .gitignore > /dev/null || echo "$$p/*" >> .gitignore ; done ; \
popd > /dev/null

installcomplete:
	@echo "*** $@ ***"

uninstallcomplete:
	@echo "*** $@ ***"

clean:
	@echo "*** $@ ***"
	rm -rf .install .usage ; \
pushd .. > /dev/null ; \
[ -f var/run/*.pid ] && ./pgws.sh fcgi stop ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc}/* ; do rm -rf $$p ; done ; \
popd > /dev/null

uninstall-db:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f var/.build.pkg ] && ./pgws.sh db drop pkg ; \
[ -f var/.build.pgws ] && ./pgws.sh db drop ; \
popd > /dev/null

uninstall-dirs:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc} ; do rmdir $$p 2> /dev/null ; done ; \
for p in var pkg conf ; do rmdir $$p 2> /dev/null ; done ; \
popd > /dev/null

clean-conf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
for p in conf/*.{json,conf} ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
for f in pgws.sh pgws.cfg ; do [ -f $$f ] && diff --brief $$f pgws/ws/eg/$$f && rm $$f ; done ; \
popd > /dev/null

clean-pkg:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -s var/i18n ] && [ var/i18n -ef pkg/i18n/src/templates ] && rm var/i18n ; \
[ -d pkg ] && for p in pkg/* ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
popd > /dev/null

clean-lib:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
[ -d lib ] && find lib -name *.pm -printf "%p %l\n" | while read p s ; do \
  if [[ "$$s" && "$$s" != "$${s#$$R/pgws/ws/lib/}" ]] ; then \
    rm $$p ; \
  else \
    sr=$${s#$$R/pkg/} ; \
    sf=$$R/pgws/ws/eg/pkg/$$sr ; \
    if [[ "$$s" ]] && [[ "$$sf" ]] && [[ "$$s" != "$$sr" ]] && [ -f $$sf ] && [ $$p -ef $$sf ] ; then \
      rm $$p ; \
    else \
      echo "Unknown file: $$p" ; \
    fi ; \
  fi ; \
done ; \
[ -d lib ] && find lib -type d | while read p ; do rmdir -p $$p 2>> /dev/null ; done ; \
popd > /dev/null

uninstall: uninstall-db clean clean-lib clean-pkg clean-conf uninstall-dirs uninstallcomplete

test:
	CORELIB=$$PWD/ws/lib ; \
	for f in ws/t/*.t ws/eg/pkg/*/t/*.t ; do \
	d=$$(dirname $$f) ; \
	n=$$(basename $$f) ; \
	pushd $$d/.. ; \
	perl -I$$CORELIB t/$$n ; \
	popd ; \
	done