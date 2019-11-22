FROM postgres:9.6.13-alpine

MAINTAINER Mathias Schilling <m@matchilling.com>

ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=tronald

COPY 'migration/0001/initial_setup_database_schema.sql' '/docker-entrypoint-initdb.d/01-initial_setup_database_schema.sql'
COPY 'migration/0002/initial_setup_stored_procedures.sql' '/docker-entrypoint-initdb.d/02-initial_setup_stored_procedures.sql'
COPY 'data/author.sql' '/docker-entrypoint-initdb.d/03-author.sql'
COPY 'data/quote_source.sql' '/docker-entrypoint-initdb.d/04-quote_source.sql'
COPY 'data/quote.sql' '/docker-entrypoint-initdb.d/05-quote.sql'
