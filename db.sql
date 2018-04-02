-- -------------------------------- --
--     Base de Datos de MiLugar     --
-- -------------------------------- --
-- Creado por : David Pardo Urrutia --
--              <dpardou@gmail.com> --
-- -------------------------------- --

-- Creación de usuario administrador.

CREATE ROLE "milugar_admin"
    WITH
        LOGIN
        SUPERUSER
        CREATEDB
        CREATEROLE
        REPLICATION
        BYPASSRLS
        PASSWORD 'milugar_admin'
;

-- Creación de usuario normal.

CREATE ROLE "milugar_user"
    WITH
        LOGIN
        NOSUPERUSER
        NOCREATEDB
        NOCREATEROLE
        NOREPLICATION
        NOBYPASSRLS
        PASSWORD 'milugar_user'
;

-- Creación de Base de Datos.

CREATE DATABASE "milugar"
    WITH
        OWNER "milugar_admin"
        TEMPLATE "template0"
;

-- Conexión a Base de Datos

\c "milugar" "milugar_admin"

-- Tabla para regiones.

CREATE TABLE "public"."regions_table" (
    "id" SMALLSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "name" CHARACTER VARYING (255) NOT NULL,
    "official_name" CHARACTER VARYING (255) NOT NULL,

    CONSTRAINT "regions_table_pk"
        PRIMARY KEY "id",

    CONSTRAINT "regions_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "regions_table_uk_name"
        UNIQUE ("name"),

    CONSTRAINT "regions_table_uk_official_name"
        UNIQUE ("official_name")
);

-- Tabla para provincias.

CREATE TABLE "public"."provinces_table" (
    "id" SMALLSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "official_name" CHARACTER VARYING (255) NOT NULL,
    "region_id" SMALLINT NOT NULL,

    CONSTRAINT "provinces_table_pk"
        PRIMARY KEY "id",

    CONSTRAINT "provinces_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "provinces_table_uk_official_name"
        UNIQUE ("official_name"),

    CONSTRAINT "provinces_table_fk_regions_table"
        FOREIGN KEY ("region_id")
        REFERENCES "public"."regions_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Tabla para comunas.

CREATE TABLE "public"."comunes_table" (
    "id" SMALLSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "official_name" CHARACTER VARYING (255) NOT NULL,
    "province_id" SMALLINT NOT NULL,

    CONSTRAINT "comunes_table_pk"
        PRIMARY KEY "id",

    CONSTRAINT "comunes_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "comunes_table_official_name"
        UNIQUE ("official_name"),

    CONSTRAINT "comunes_table_fk_provinces_table"
        FOREIGN KEY ("province_id")
        REFERENCES "public"."provinces_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Tabla para estacionamientos.

CREATE TABLE "public"."parking_lots_table" (
    "id" BIGSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "street_address" CHARACTER VARYING (255) NOT NULL,
    "number" CHARACTER VARYING (16) DEFAULT NULL,
    "latitude" NUMERIC(38,30) DEFAULT NULL,
    "longitude" NUMERIC(38, 30) DEFAULT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 0,
    "orientation" CHARACTER VARYING (2) NOT NULL,
    "sidewalk" CHARACTER VARYING (2) NOT NULL,
    "is_signaled" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "updated_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "deleted_at" TIMESTAMP DEFAULT NULL,
    "comune_id" SMALLINT NOT NULL,

    CONSTRAINT "parking_lots_table_pk"
        PRIMARY KEY ("id"),

    CONSTRAINT "parking_lots_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "parking_lots_table_fk_comune_table"
        FOREIGN KEY ("comune_id")
        REFERENCES "public"."comunes_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Tabla para usuarios.

CREATE TABLE "public"."users_table" (
    "id" BIGSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "first_name" CHARACTER VARYING (255) NOT NULL,
    "last_name" CHARACTER VARYING (255) NOT NULL,
    "email" CHARACTER VARYING (255) NOT NULL,
    "salt" CHARACTER VARYING (255) NOT NULL,
    "hashed_password" CHARACTER VARYING (255) NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "updated_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "deleted_at" TIMESTAMP DEFAULT NULL,

    CONSTRAINT "users_table_pk"
        PRIMARY KEY ("id"),

    CONSTRAINT "users_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "users_table_uk_email"
        UNIQUE ("email")
);

-- Tabla para ubicaciones.

CREATE TABLE "public"."locations_table" (
    "id" BIGSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "latitude" NUMERIC(38, 35) NOT NULL,
    "longitude" NUMERIC(38, 35) NOT NULL,
    "user_id" BIGINT NOT NULL,

    CONSTRAINT "locations_table_pk"
        PRIMARY KEY ("id"),

    CONSTRAINT "locations_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "locations_table_fk_users_table"
        FOREIGN KEY ("user_id")
        REFERENCES "public"."users_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT 
);

-- Tabla para mensajes.

CREATE TABLE "public"."messages_table" (
    "id" BIGSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "updated_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "deleted_at" TIMESTAMP DEFAULT NULL,
    "user_id" BIGINT NOT NULL,

    CONSTRAINT "messages_table_pk"
        PRIMARY KEY ("id"),

    CONSTRAINT "messages_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "messages_table_fk_users_table"
        FOREIGN KEY ("user_id")
        REFERENCES "public"."users_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

-- Tabla para denuncias.

CREATE TABLE "public"."reports_table" (
    "id" BIGSERIAL NOT NULL,
    "uuid" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" BIGINT NOT NULL,
    "parking_lot_id" BIGINT NOT NULL,
    "picture" bytea NOT NULL,
    "description" TEXT DEFAULT NULL,
    "created_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "updated_at" TIMESTAMP NOT NULL DEFAULT current_timestamp,
    "deleted_at" TIMESTAMP DEFAULT NULL,

    CONSTRAINT "reports_table_pk"
        PRIMARY KEY ("id"),

    CONSTRAINT "reports_table_uk_uuid"
        UNIQUE ("uuid"),

    CONSTRAINT "reports_table_fk_users_table"
        FOREIGN KEY ("user_id")
        REFERENCES "public"."users_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT,

    CONSTRAINT "reports_table_fk_parking_lots_table"
        FOREIGN KEY ("parking_lot_id")
        REFERENCES "public"."parking_lots_table" ("id")
        ON UPDATE RESTRICT
        ON DELETE RESTRICT
);

