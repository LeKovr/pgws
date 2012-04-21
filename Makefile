.PHONY: all help usage conf pkg var masterconf
SHELL           = /bin/bash
DATE		= `date +%y%m%d`

define HELP
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
  PGWS - Postgresql WebServices.

  For install into upper dir:
    make install

  For check if all requirements are satisfied:
    make test
endef
export HELP


help:
	@echo "$$HELP"

all: help
usage: help

install: test conf var pkg masterconf gitignore installcomplete

conf:
	pushd .. > /dev/null ; [ -d conf ] || mkdir conf ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in conf/* ; do [ -f $$root/$$p ] || ln  ${PWD}/ws/eg/$$p $$root/$$p ; done ; \
popd > /dev/null

pkg:
	pushd .. > /dev/null ; [ -d pkg ] || mkdir pkg ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in pkg/* ; do [ -f $$root/$$p ] || cp -pr $$p $$root/pkg/ ; done ; \
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

clean:
	rm -rf .install .usage

test:
	perl ws/t/01-compile.t
	pwd
