#!/usr/bin/env bash
#
# Copyright (c) 2010, 2012 Tender.Pro http://tender.pro.
# This file is part of PGWS - Postgresql WebServices.
#
# pgws.sh - PGWS control script

PGWS_ROOT=$PWD

. pgws.cfg

. $PGWS_ROOT/$PGWS/$PGWS_WS/bin/pgwsctl.sh "$@"
