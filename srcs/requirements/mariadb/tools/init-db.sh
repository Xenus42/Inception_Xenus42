#!/bin/bash

set -e
: "${MYSQL_DATABASE:?MYSQL_DATABASE n'est pas définie}"
: "${MYSQL_USER:?MYSQL_USER n'est pas défini}"
: "${MYSQL_PASSWORD:?MYSQL_PASSWORD n'est pas défini}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD n'est pas défini}"