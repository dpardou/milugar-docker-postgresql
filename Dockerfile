FROM postgres:alpine
MAINTAINER David Pardo Urrutia <dpardou@gmail.com>

COPY db.sql /docker-entrypoint-initdb.d/db.sql
