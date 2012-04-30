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

install: test conf var pkg masterconf installcomplete

conf:
	pushd .. > /dev/null ; [ -d conf ] || mkdir conf ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in conf/*.{json,conf} ; do [ -f $$root/$$p ] || ln -s  ${PWD}/ws/eg/$$p $$root/$$p ; done ; \
popd > /dev/null

pkg:
	pushd .. > /dev/null ; [ -d pkg ] || mkdir pkg ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in pkg/* ; do [ -e $$root/$$p ] || ln -s $$PWD/$$p $$root/$$p ; done ; \
popd > /dev/null

var:
	pushd .. > /dev/null ; \
[ -d var ] || mkdir var ; \
for p in build cache log run tmpl tmpc ; do [ -d var/$$p ] || mkdir -m g+w var/$$p ; done ; \
popd > /dev/null

masterconf:
	pushd .. > /dev/null ; \
[ -f pgws.cfg ] || ln ${PWD}/ws/eg/pgws.cfg pgws.cfg ; \
[ -f pgws.sh ] || ln ${PWD}/ws/eg/pgws.sh pgws.sh ; \
popd > /dev/null

gitignore:
	pushd .. > /dev/null ; \
[ -f .gitignore ] || touch .gitignore ; \
for p in pgws var conf  ; do grep -E "^$$p" .gitignore > /dev/null || echo "$$p/*" >> .gitignore ; done ; \
popd > /dev/null

installcomplete:
	@echo "Install complete."

uninstallcomplete:
	@echo "UnInstall complete."

clean:
	rm -rf .install .usage ; \
pushd .. > /dev/null ; \
[ -f var/run/*.pid ] && ./pgws.sh fcgi stop ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc}/* ; do rm -rf $$p ; done ; \
popd > /dev/null

uninstall-db:
	pushd .. > /dev/null ; \
[ -f var/.build.pkg ] && ./pgws.sh db drop pkg ; \
[ -f var/.build.pgws ] && ./pgws.sh db drop ; \
popd > /dev/null

uninstall-dirs:
	pushd .. > /dev/null ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc} ; do rmdir $$p 2> /dev/null ; done ; \
for p in var pkg conf ; do rmdir $$p 2> /dev/null ; done ; \
popd > /dev/null

clean-conf:
	pushd .. > /dev/null ; \
for p in conf/*.{json,conf} ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
for f in pgws.sh pgws.cfg ; do diff --brief $$f pgws/ws/eg/$$f && rm $$f ; done ; \
popd > /dev/null

clean-pkg:
	pushd .. > /dev/null ; \
[ -s var/i18n ] && [ var/i18n -ef pkg/i18n/src/templates ] && rm var/i18n ; \
for p in pkg/* ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
popd > /dev/null

clean-lib:
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
find lib -name *.pm -printf "%p %l\n" | while read p s ; do \
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
find lib -type d | while read p ; do rmdir -p $$p 2>> /dev/null ; done ; \
popd > /dev/null

uninstall: uninstall-db clean clean-lib clean-pkg clean-conf uninstall-dirs uninstallcomplete

test:
	perl ws/t/01-compile.t
	pwd
