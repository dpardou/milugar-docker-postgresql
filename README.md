# Docker de PostgreSQL para MiLugar

Base de datos PostgreSQL para MiLugar.

## ¿Cómo ejecutar?

Teniendo Docker instalado, ejecutar los siguientes comandos:

    docker build --rm -t docker-postgresql .
    docker create -d -p 5432:5432 --name docker-pgsql-server docker-postgresql
    docker start docker-pgsql-server

