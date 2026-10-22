FROM postgres:17.6

COPY ./src/postgres/init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE ${POSTGRES_PORT}