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

install: test data var pkg lib lib-pkg ctl setups tmpl nginxconf masterconf installcomplete

# ------------------------------------------------------------------------------

data:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; d=data/file/upload ; \
[ -d $$d ] || mkdir -p $$d; \
for p in {0..9} ; do [ -d $$d/$$p ] || mkdir -m g+w $$d/$$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

var:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -d var ] || mkdir var ; \
for p in build cache conf ctl log run tmpl tmpc www ; do [ -d var/$$p ] || mkdir -m g+w var/$$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

pkg:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; [ -d pkg ] || mkdir pkg ; root=$$PWD ; popd > /dev/null ; \
pushd ws/eg > /dev/null ; \
for p in pkg/* ; do [ -e $$root/$$p ] || ln -s $$PWD/$$p $$root/$$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

lib:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
[ -d lib ] || mkdir lib ; \
pushd $$R/pgws/ws/ ; \
find lib -name *.pm -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -d $$R/$$d ] || mkdir -p $$R/$$d ; \
  [ -e $$R/$$d/$$n ] || ln -s $$R/pgws/ws/$$d/$$n $$R/$$d/$$n ; \
done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

lib-pkg:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
[ -d lib ] || mkdir lib ; \
for p in pkg/* ; do if [ -d $$R/$$p/lib ] ; then \
pushd $$R/$$p ; \
find lib -name *.pm -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -d $$R/$$d ] || mkdir -p $$R/$$d ; \
  [ -e $$R/$$d/$$n ] || ln -s $$R/$$p/$$d/$$n $$R/$$d/$$n ; \
done ; \
popd > /dev/null ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

tmpl:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -d $$R/pkg/$$p ] && [ -d $$R/pkg/$$p/tmpl ] ; then \
pushd $$R/pkg/$$p/tmpl ; \
for d in * ; do if [[ "$$d" == "config.tt2" ]] ; then \
  [ -e $$R/var/tmpl/$$p.tt2 ] || ln -s ../../pkg/$$p/tmpl/$$d $$R/var/tmpl/$$p.tt2 ; \
  elif [[ "$$d" == "macro" ]] ; then \
  [ -d $$R/var/tmpl/$$d ] || mkdir -p $$R/var/tmpl/$$d ; \
for n in $$d/*.tt2 ; do \
  [ -e $$R/var/tmpl/$$n ] || ln -s ../../../pkg/$$p/tmpl/$$n $$R/var/tmpl/$$n ; \
done else \
  [ -d $$R/var/tmpl/$$d ] || mkdir -p $$R/var/tmpl/$$d ; \
  [ -e $$R/var/tmpl/$$d/$$p ] || ln -s ../../../pkg/$$p/tmpl/$$d $$R/var/tmpl/$$d/$$p ; \
fi ; done ; \
popd > /dev/null ; \
fi ; \
if [ -d $$R/pkg/$$p ] && [ -d $$R/pkg/$$p/www ] ; then \
pushd $$R/pkg/$$p/www ; \
for d in $$(ls -A) ; do \
if [ -d $$d ] ; then \
  [ -d $$R/var/www/$$d ] || mkdir -p $$R/var/www/$$d ; \
  [ -e $$R/var/www/$$d/$$p ] || ln -s ../../../pkg/$$p/www/$$d $$R/var/www/$$d/$$p ; \
else \
  [ -e $$R/var/www/$$d ] || ln -s ../../pkg/$$p/www/$$d $$R/var/www/$$d ; \
fi \
done ; \
popd > /dev/null ; \
fi ; \
done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

ctl:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
find pgws/ws/bin -name *ctl.sh -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -e $$R/var/ctl/$$n ] || ln -s $$R/$$d/$$n $$R/var/ctl/$$n ; \
done ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -d $$R/pkg/$$p/bin ] ; then \
find pkg/$$p/bin -name *ctl.sh -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -e $$R/var/ctl/$$n ] || ln -s $$R/$$d/$$n $$R/var/ctl/$$n ; \
done ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

setups:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -e $$R/pkg/$$p/setup.sh ] ; then \
pushd $$R/pkg/$$p ; $$SHELL setup.sh ; popd > /dev/null ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

nginxconf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; d=nginx ; R=$$PWD ; \
    [ -d $$d ] || mkdir -p $$d; \
    for f in $$R/pgws/ws/eg/conf/*.conf; \
        do if [ ! -e $$d/$$(basename $$f) ] ; then \
            if [[ "$$R" == "/home/data/sampleapp" ]] ; then ln -s $$f -t $$d ; \
            else cp $$f $$d/ ; sed -i "s|/home/data/sampleapp|$$PWD|g" $$d/*.conf ; fi ;\
        fi ; done ; \
	popd > /dev/null

# ------------------------------------------------------------------------------

masterconf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f config.json ] || cp ${PWD}/ws/eg/config.json . ; \
[ -f pgws.sh ] || cp ${PWD}/ws/eg/pgws.sh pgws.sh ; \
popd > /dev/null

# ------------------------------------------------------------------------------

gitignore:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f .gitignore ] || touch .gitignore ; \
for p in pgws var conf  ; do grep -E "^$$p" .gitignore > /dev/null || echo "$$p/*" >> .gitignore ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

installcomplete:
	@echo "*** $@ ***"

uninstallcomplete:
	@echo "*** $@ ***"

# ------------------------------------------------------------------------------

clean:
	@echo "*** $@ ***"
	rm -rf .install .usage ; \
pushd .. > /dev/null ; \
[ -f var/run/*.pid ] && ./pgws.sh fcgi stop ; \
[ -d var ] && for p in var/{build,cache,ctl,log,run,tmpl,tmpc}/* ; do rm -rf $$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

uninstall-db:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -f var/.build.pkg ] && ./pgws.sh db drop pkg ; \
[ -f var/.build.pgws ] && ./pgws.sh db drop ; \
popd > /dev/null

# ------------------------------------------------------------------------------

uninstall-dirs:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc} ; do rmdir $$p 2> /dev/null ; done ; \
for p in var pkg conf ; do rmdir $$p 2> /dev/null ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-conf:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
for p in conf/*.{json,conf} ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
for f in config.json pgws.sh ; do [ -f $$f ] && diff --brief $$f pgws/ws/eg/$$f && rm $$f ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-pkg:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
[ -s var/i18n ] && [ var/i18n -ef pkg/i18n/src/templates ] && rm var/i18n ; \
[ -d pkg ] && for p in pkg/* ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-lib:
	@echo "*** $@ ***"
	pushd .. > /dev/null ; \
R=$$(dirs +0) ; \
[ -d lib ] && find lib -name *.pm -print | while read f ; do \
  s=$$(readlink $$f) ; p=$$f ; \
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

# ------------------------------------------------------------------------------

uninstall: uninstall-db clean clean-lib clean-pkg clean-conf uninstall-dirs uninstallcomplete

# ------------------------------------------------------------------------------

test:
	CORELIB=$$PWD/ws/lib ; \
	for f in ws/t/*.t ws/eg/pkg/*/t/*.t ; do \
	d=$$(dirname $$f) ; \
	n=$$(basename $$f) ; \
	[[ "$$n" == "03-critic.t" ]] && continue ; \
	pushd $$d/.. ; \
	perl -I$$CORELIB -Ilib t/$$n ; \
	popd ; \
	done

critic:
	CORELIB=$$PWD/ws/lib ; \
	for f in ws/t/*.t ws/eg/pkg/*/t/*.t ; do \
	d=$$(dirname $$f) ; \
	n=$$(basename $$f) ; \
	[[ "$$n" == "03-critic.t" ]] || continue ; \
	pushd $$d/.. ; \
	perl -I$$CORELIB -Ilib t/$$n ; \
	popd ; \
	done
