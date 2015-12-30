.PHONY: all help usage conf pkg var masterconf
SHELL               = /bin/bash
DATE                = `date +%y%m%d`

ROOT_DEFAULT        = /home/data/sampleapp
WWW_HOST_DEFAULT    = pgws.local
FCGI_SOCKET_DEFAULT = back.test.local:9001
FE_COOKIE_DEFAULT   = PGWS_SID
FE_LAYOUTS_DEFAULT  = style02 style01
FE_SKIN_DEFAULT     = light

WWW_HOST           ?= $(WWW_HOST_DEFAULT)
WWW_IP             ?= $(WWW_HOST)
FCGI_SOCKET        ?= $(FCGI_SOCKET_DEFAULT)
FE_COOKIE          ?= $(FE_COOKIE_DEFAULT)
FE_LAYOUTS         ?= $(FE_LAYOUTS_DEFAULT)
FE_SKIN            ?= $(FE_SKIN_DEFAULT)

PGWS_ROOT          ?= $(shell dirname $$PWD)
FILE_STORE_ROOT    ?= $(PGWS_ROOT)/data
FILE_URI           ?= /file

# пользователь, под которым работает демон FCGI
DAEMON_USER        ?= apache
DB_CONNECT         ?= dbi:Pg:dbname=pgws;user=apache
PROCESS_PREFIX     ?= pgws-dev
SRV_DEBUG          ?= 1

TM_CMD             ?= 
PACKAGES           ?= fs job acc apidoc ev wiki app_sample app_common i18n style02

NGINX_CFG_DIR       = nginx

define HELP
  Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
  PGWS - Postgresql WebServices.

  This makefile has the following general targets:


install      - Install project files into upper dir
test         - Check if all requirements are satisfied:
uninstall    - Erase any PGWS DB objects and any generated files:

install-db   - DB create, init, init pkg, clean cache
uninstall-db - stop services if needed, erase any PGWS DB objects
drop-db      - Drop DB objects exclude persistent data (wsd.*)

start        - Start all services, install-db if needed
stop         - Stop all services

rebuild      - drop-db, then start

endef
export HELP


help:
	@echo "$$HELP"

all: help
usage: help

install: test data var pkg lib lib-pkg ctl setups tmpl conf installcomplete
conf: psw-conf nginx-conf master-conf
restart: stop start

# ------------------------------------------------------------------------------

data:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; d=data/file/upload ; \
[ -d $$d ] || mkdir -p $$d; \
for p in {0..9} ; do [ -d $$d/$$p ] || mkdir -m g+w $$d/$$p ; done ; \
mkdir -m g+w data/file/www-cache ; \
popd > /dev/null

# ------------------------------------------------------------------------------

var:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d var ] || mkdir var ; \
for p in build/log cache conf ctl log run tmpl tmpc www ; do [ -d var/$$p ] || mkdir -p -m g+w var/$$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

pkg:
	@echo "*** $@ ***"
	[ -d $(PGWS_ROOT)/pkg ] || mkdir $(PGWS_ROOT)/pkg ; \
pushd ws/eg > /dev/null ; \
for p in pkg/* ; do [ -e $(PGWS_ROOT)/$$p ] || ln -s ../pgws/ws/eg/$$p $(PGWS_ROOT)/$$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

lib:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d lib ] || mkdir lib ; \
pushd $(PGWS_ROOT)/pgws/ws/ ; \
find lib -name *.pm -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -d $(PGWS_ROOT)/$$d ] || mkdir -p $(PGWS_ROOT)/$$d ; \
  [ -e $(PGWS_ROOT)/$$d/$$n ] || ln -s $(PGWS_ROOT)/pgws/ws/$$d/$$n $(PGWS_ROOT)/$$d/$$n ; \
done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

lib-pkg:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d lib ] || mkdir lib ; \
for p in pkg/* ; do if [ -d $(PGWS_ROOT)/$$p/lib ] ; then \
pushd $(PGWS_ROOT)/$$p ; \
find lib -name *.pm -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -d $(PGWS_ROOT)/$$d ] || mkdir -p $(PGWS_ROOT)/$$d ; \
  [ -e $(PGWS_ROOT)/$$d/$$n ] || ln -s $(PGWS_ROOT)/$$p/$$d/$$n $(PGWS_ROOT)/$$d/$$n ; \
done ; \
popd > /dev/null ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

tmpl:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -d $(PGWS_ROOT)/pkg/$$p ] && [ -d $(PGWS_ROOT)/pkg/$$p/tmpl ] ; then \
pushd $(PGWS_ROOT)/pkg/$$p/tmpl ; \
for d in * ; do \
  [ -d $(PGWS_ROOT)/var/tmpl/$$d ] || mkdir -p $(PGWS_ROOT)/var/tmpl/$$d ; \
  [ -e $(PGWS_ROOT)/var/tmpl/$$d/$$p ] || ln -s ../../../pkg/$$p/tmpl/$$d $(PGWS_ROOT)/var/tmpl/$$d/$$p ; \
done ; \
popd > /dev/null ; \
fi ; \
if [ -d $(PGWS_ROOT)/pkg/$$p ] && [ -d $(PGWS_ROOT)/pkg/$$p/www ] ; then \
pushd $(PGWS_ROOT)/pkg/$$p/www ; \
for d in $$(ls -A) ; do \
if [ -d $$d ] ; then \
  [ -d $(PGWS_ROOT)/var/www/$$d ] || mkdir -p $(PGWS_ROOT)/var/www/$$d ; \
  [ -e $(PGWS_ROOT)/var/www/$$d/$$p ] || ln -s ../../../pkg/$$p/www/$$d $(PGWS_ROOT)/var/www/$$d/$$p ; \
else \
  [ -e $(PGWS_ROOT)/var/www/$$d ] || ln -s ../../pkg/$$p/www/$$d $(PGWS_ROOT)/var/www/$$d ; \
fi \
done ; \
popd > /dev/null ; \
fi ; \
done ; \
popd > /dev/null ; \
for l in $(FE_LAYOUTS) ; do \
if [ -f $(PGWS_ROOT)/var/www/css/$$l/skin/$(FE_SKIN).css ] ; then \
[ -d $(PGWS_ROOT)/var/www/css/pgws ] || mkdir $(PGWS_ROOT)/var/www/css/pgws ; \
pushd $(PGWS_ROOT)/var/www/css/pgws > /dev/null ; \
[ -L skin.css ] && rm skin.css ; \
[ -L skin ] && rm skin ; \
ln -s ../$$l/skin skin ; \
ln -s skin/$(FE_SKIN).css skin.css ; \
fi ; \
break ; done

# only first from FE_LAYOUTS used

# ------------------------------------------------------------------------------

ctl:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
find pgws/ws/bin -name *ctl.sh -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -e $(PGWS_ROOT)/var/ctl/$$n ] || ln -s ../../$$d/$$n $(PGWS_ROOT)/var/ctl/$$n ; \
done ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -d $(PGWS_ROOT)/pkg/$$p/bin ] ; then \
find pkg/$$p/bin -name *ctl.sh -print | while read f ; do \
  d=$$(dirname $$f) ; n=$$(basename $$f) ; \
  [ -e $(PGWS_ROOT)/var/ctl/$$n ] || ln -s ../../$$d/$$n $(PGWS_ROOT)/var/ctl/$$n ; \
done ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

setups:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
PD=$$(ls pkg/) ; \
for p in $$PD ; do if [ -e $(PGWS_ROOT)/pkg/$$p/setup.sh ] ; then \
pushd $(PGWS_ROOT)/pkg/$$p ; $$SHELL setup.sh ; popd > /dev/null ; \
fi ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------
psw-conf:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null  ; \
for f in upload job default ; do \
  if [ ! -e var/build/psw_$$f ] ; then \
    LC_ALL=C < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c$${1:-16} > var/build/psw_$$f ; \
  fi ; \
done ; \
popd > /dev/null

# ------------------------------------------------------------------------------
nginx-conf:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d $(NGINX_CFG_DIR) ] || mkdir -p $(NGINX_CFG_DIR); \
for f in $(PGWS_ROOT)/pgws/ws/eg/conf/{nginx,pgws}-*.conf; do \
  bnf=$$(basename $$f) ; \
  if [ ! -e $(NGINX_CFG_DIR)/$$bnf ] ; then \
    if [[ "$(PGWS_ROOT)" == "$(ROOT_DEFAULT)" && "$(WWW_HOST)" == "$(WWW_HOST_DEFAULT)" \
      && "$(FCGI_SOCKET)" == "$(FCGI_SOCKET_DEFAULT)" && "$(FE_COOKIE_DEFAULT)" == "$(FE_COOKIE)" ]] ; then \
      echo "$$bnf: Keeping original configs" ; ln -s $$f -t $(NGINX_CFG_DIR) ; \
    else \
      echo "$$bnf: Setup for $(PGWS_ROOT) $(WWW_HOST) $(FCGI_SOCKET) $(FE_COOKIE)" ; \
      sed -e "s|$(ROOT_DEFAULT)|$(PGWS_ROOT)|g" \
        -e "s|$(WWW_HOST_DEFAULT):80|$(WWW_IP):80|g" \
        -e "s|$(WWW_HOST_DEFAULT)|$(WWW_HOST)|g" \
        -e "s|$(FE_COOKIE_DEFAULT)|$(FE_COOKIE)|" \
        -e "s|$(FCGI_SOCKET_DEFAULT)|$(FCGI_SOCKET)|g" $$f > $(NGINX_CFG_DIR)/$$bnf ; \
    fi ;\
  fi ; \
done ; \
p=$$(cat var/build/psw_upload) ; f=pgws-upload.conf ; \
[ -e $(NGINX_CFG_DIR)/$$f ] || sed \
  -e "s|=PSW_UPLOAD=|$$p|" \
  -e "s|=FILE_STORE_ROOT=|$(FILE_STORE_ROOT)|g" \
  -e "s|=FILE_URI=|$(FILE_URI)|g" \
  pgws/ws/eg/conf/$${f}.inc > $(NGINX_CFG_DIR)/$$f ; \
f=pgws-cache.conf ; \
[ -e $(NGINX_CFG_DIR)/$$f ] || sed \
  -e "s|=FILE_STORE_ROOT=|$(FILE_STORE_ROOT)|g" \
  -e "s|=FILE_URI=|$(FILE_URI)|g" \
  pgws/ws/eg/conf/$${f}.inc > $(NGINX_CFG_DIR)/$$f ; \
popd > /dev/null

#      sed -e "s|$(ROOT_DEFAULT)|$$PWD|g;s|$(WWW_HOST_DEFAULT)|$(WWW_HOST)|g;s|$(FCGI_SOCKET_DEFAULT)|$(FCGI_SOCKET)|g" $$f > $(NGINX_CFG_DIR)/$$bnf ; \

# ------------------------------------------------------------------------------
master-conf:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
if [ ! -f config.json ] ; then \
  p_up=$$(cat var/build/psw_upload) ; p_job=$$(cat var/build/psw_job) ; \
  sed -e "s|$(ROOT_DEFAULT)|$(PGWS_ROOT)|g" \
    -e "s|=PSW_UPLOAD=|$$p_up|" \
    -e "s|=PSW_JOB=|$$p_job|" \
    -e "s|=FILE_STORE_ROOT=|$(FILE_STORE_ROOT)|g" \
    -e "s|=FILE_URI=|$(FILE_URI)|g" \
    -e "s|=DAEMON_USER=|$(DAEMON_USER)|" \
    -e "s|=DB_CONNECT=|$(DB_CONNECT)|" \
    -e "s|=FCGI_SOCKET=|$(FCGI_SOCKET)|" \
    -e "s|=PROCESS_PREFIX=|$(PROCESS_PREFIX)|" \
    -e "s|=SRV_DEBUG=|$(SRV_DEBUG)|" \
    -e "s|=TM_CMD=|$(TM_CMD)|" \
    -e "s|=FE_COOKIE=|$(FE_COOKIE)|" \
    -e "s|=FE_LAYOUTS=|$(FE_LAYOUTS)|" \
    -e "s|=PACKAGES=|$(PACKAGES)|" \
    pgws/ws/eg/conf/config.json.inc > config.json ; \
fi ; \
[ -f pgws.sh ] || { cp pgws/ws/eg/conf/pgws.sh.inc pgws.sh && chmod +x pgws.sh ; } ; \
popd > /dev/null

# ------------------------------------------------------------------------------
gitignore:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
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
pushd $(PGWS_ROOT) > /dev/null ; \
[ -f var/run/*-tm.pid ] && ./pgws.sh tm stop ; \
[ -f var/run/*-job.pid ] && ./pgws.sh job stop ; \
[ -f var/run/*-fcgi.pid ] && ./pgws.sh fcgi stop ; \
[ -d var ] && for p in var/{build,cache,ctl,log,run,tmpl,tmpc}/* ; do rm -rf $$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------
install-db:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
{ [ -f var/.build.pgws ] || ./pgws.sh db create ; } && \
{ [ -f var/.build.pgws ] || ./pgws.sh db init ; } && \
{ [ -f var/.build.pkg ] || ./pgws.sh db init pkg ; } && \
./pgws.sh cache clear && \
popd > /dev/null && exit 0 ; \
exit 1

# ------------------------------------------------------------------------------
uninstall-db: stop
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
{ [ -f var/.build.pkg ] && ./pgws.sh db drop pkg || [ ! -f var/.build.pkg ] ; } && \
{ [ -f var/.build.pgws ] && ./pgws.sh db erase_force || [ ! -f var/.build.pgws ] ; } && \
popd > /dev/null && exit 0 ; \
exit 1

# ------------------------------------------------------------------------------
drop-db: stop
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
{ [ -f var/.build.pkg ] && ./pgws.sh db drop pkg || [ ! -f var/.build.pkg ] ; } && \
{ [ -f var/.build.pgws ] && ./pgws.sh db drop || [ ! -f var/.build.pgws ] ; } && \
popd > /dev/null

# ------------------------------------------------------------------------------

dump-db:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
./pgws.sh db dump ; \
popd > /dev/null

# ------------------------------------------------------------------------------

start: install-db
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
./pgws.sh cache clear ; \
./pgws.sh fcgi start ; \
sleep 2 ; \
./pgws.sh job start ; \
./pgws.sh tm start ; \
popd > /dev/null

# ------------------------------------------------------------------------------

stop:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -f var/run/*-tm.pid ] && ./pgws.sh tm stop ; \
[ -f var/run/*-job.pid ] && ./pgws.sh job stop ; \
[ -f var/run/*-fcgi.pid ] && ./pgws.sh fcgi stop ; \
popd > /dev/null

rebuild: drop-db start

reinstall: uninstall-db start

# ------------------------------------------------------------------------------

uninstall-dirs:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d var ] && for p in var/{build,cache,log,run,tmpl,tmpc} ; do rmdir $$p 2> /dev/null ; done ; \
for p in var pkg conf ; do rmdir $$p 2> /dev/null ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-conf:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
for p in $(NGINX_CFG_DIR)/*.conf ; do echo "==$$p" ; if [ -L $$p ] ; then rm $$p ; else mv $$p $$p.save ; fi ; done ; \
for f in config.json pgws.sh ; do [ -e $$f ] && mv $$f $$f.save ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-pkg:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -s var/i18n ] && [ var/i18n -ef pkg/i18n/src/templates ] && rm var/i18n ; \
[ -d pkg ] && for p in pkg/* ; do [ $$p -ef pgws/ws/eg/$$p ] && rm $$p ; done ; \
popd > /dev/null

# ------------------------------------------------------------------------------

clean-lib:
	@echo "*** $@ ***"
	pushd $(PGWS_ROOT) > /dev/null ; \
[ -d lib ] && find lib -name *.pm -print | while read f ; do \
  s=$$(readlink $$f) ; p=$$f ; \
  if [[ "$$s" && "$$s" != "$${s#$(PGWS_ROOT)/pgws/ws/lib/}" ]] ; then \
    rm $$p ; \
  else \
    sr=$${s#$(PGWS_ROOT)/pkg/} ; \
    sf=$(PGWS_ROOT)/pgws/ws/eg/pkg/$$sr ; \
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
	CORELIB=$(PGWS_ROOT)/pgws/ws/lib ; \
	for f in ws/t/*.t ws/eg/pkg/*/t/*.t ; do \
	d=$$(dirname $$f) ; \
	n=$$(basename $$f) ; \
	[[ "$$n" == "03-critic.t" ]] && continue ; \
	pushd $$d/.. ; \
	perl -I$$CORELIB -Ilib t/$$n ; \
	popd ; \
	done

# ------------------------------------------------------------------------------
critic:
	CORELIB=$(PGWS_ROOT)/pgws/ws/lib ; \
	for f in ws/t/*.t ws/eg/pkg/*/t/*.t ; do \
	d=$$(dirname $$f) ; \
	n=$$(basename $$f) ; \
	[[ "$$n" == "03-critic.t" ]] || continue ; \
	pushd $$d/.. ; \
	perl -I$$CORELIB -Ilib t/$$n ; \
	popd ; \
	done

# ------------------------------------------------------------------------------
keep-sql:
	touch $(PGWS_ROOT)/var/build/keep_sql

showconf:
	@echo "*** $@ ***"
	@echo "WWW_HOST         =  $(WWW_HOST)"
	@echo "WWW_IP           =  $(WWW_IP)"
	@echo "FCGI_SOCKET      =  $(FCGI_SOCKET)"
	@echo "DAEMON_USER      =  $(DAEMON_USER)"
	@echo "DB_CONNECT       =  $(DB_CONNECT)"
	@echo "PROCESS_PREFIX   =  $(PROCESS_PREFIX)"
	@echo "SRV_DEBUG        =  $(SRV_DEBUG)"
	@echo "PGWS_ROOT        =  $(PGWS_ROOT)"
	@echo "FILE_STORE_ROOT  =  $(FILE_STORE_ROOT)"
	@echo "FILE_URI         =  $(FILE_URI)"
	@echo "TM_CMD           =  $(TM_CMD)"
	@echo "FE_COOKIE        =  $(FE_COOKIE)"
	@echo "PACKAGES         =  $(PACKAGES)"
	@echo "NGINX_CFG_DIR    =  $(NGINX_CFG_DIR)"
