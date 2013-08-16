{
  "SHELL": {
    "DAEMON_USER": "=DAEMON_USER=",
    "PACKAGES"   : "=PACKAGES=",
  },
  "ACTIVE": {
    "DB_CONNECT" : "=DB_CONNECT=",
    "FCGI_SOCKET": "=FCGI_SOCKET=",

    "PROCESS_PREFIX": "=PROCESS_PREFIX=",
    "FE_DEBUG_IFACE": =SRV_DEBUG=,

    "FILE_STORE_PATH": "=FILE_STORE_ROOT==FILE_URI=",
    "FILE_URI": "=FILE_URI=",

    "FE_REALM_UPLOAD": "upload:=PSW_UPLOAD=",

    "FE_COOKIE_MASK": "=FE_COOKIE==([\\w+/]+)==",

    "FE_LAYOUTS": "=FE_LAYOUTS=",

    "FE_CACHE_MODE": 3,
    "FE_CACHE_TTL": 5,

    "DB_LOG_CONNECT": "SELECT ws.notice('DB PID:' || pg_backend_pid())",
    "DB_SET_APPNAME": 1,
    "TM_CMD": "=TM_CMD=",
    "TM_DEBUG" : =SRV_DEBUG=,
    "TRACE_DIE" : =SRV_DEBUG=,
    "JOB_AUTH_LOGIN": "pgws-job-service",
    "JOB_AUTH_PSW" : "=PSW_JOB=",
    "JOB_DEBUG": =SRV_DEBUG=,
  },
  "inactive": {
    "DB_POID": 1,
    "TM_EVENT_REQUIRED" : 1,
  },
  "inactive_defaults": {
    "DB_SQL_APPNAME": "SET application_name = '%s'",
    "DB_PROP_FUNC": "cfg.prop_group_value_list(?, ?, ?, FALSE, NULL)",
    "DB_PROP_PREFIX": "ws.daemon",
    "FE_CACHE_STORE_DIR": "www-cache"
  },
}
