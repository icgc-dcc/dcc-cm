/*
 * Copyright (c) 2012-2013 The Ontario Institute for Cancer Research. All rights reserved.
 */

/* Script for setting up the dcc-indentifer schema using PostgreSQL 9.2.4 */

-- CREATE DATABASE dcc_identifier;
-- CREATE USER dcc WITH PASSWORD 'dcc';
-- GRANT ALL PRIVILEGES ON DATABASE dcc_identifier to dcc;
-- 
-- GRANT SELECT, INSERT ON project_ids TO dcc;
-- GRANT USAGE, SELECT ON SEQUENCE project_ids_id_seq TO dcc;
-- GRANT SELECT, INSERT ON donor_ids TO dcc;
-- GRANT USAGE, SELECT ON SEQUENCE donor_ids_id_seq TO dcc;
-- GRANT SELECT, INSERT ON sample_ids TO dcc;
-- GRANT USAGE, SELECT ON SEQUENCE sample_ids_id_seq TO dcc;
-- GRANT SELECT, INSERT ON specimen_ids TO dcc;
-- GRANT USAGE, SELECT ON SEQUENCE specimen_ids_id_seq TO dcc;
-- GRANT SELECT, INSERT ON mutation_ids TO dcc;
-- GRANT USAGE, SELECT ON SEQUENCE mutation_ids_id_seq TO dcc;

/* Initialize */

DROP TABLE IF EXISTS project_ids;
DROP TABLE IF EXISTS donor_ids;
DROP TABLE IF EXISTS specimen_ids;
DROP TABLE IF EXISTS sample_ids;
DROP TABLE IF EXISTS mutation_ids;

/* Create tables */
CREATE TABLE project_ids 
( 
  id         BIGSERIAL NOT NULL, 
  
  project_id VARCHAR(512) NOT NULL, 

  creation_release VARCHAR(512) NOT NULL, 
 
  PRIMARY KEY (project_id) 
);
CREATE TABLE donor_ids 
( 
  id         BIGSERIAL NOT NULL, 

  donor_id   VARCHAR(512) NOT NULL, 
  project_id VARCHAR(512) NOT NULL, 

  creation_release VARCHAR(512) NOT NULL, 
 
  PRIMARY KEY(donor_id, project_id) 
);
CREATE TABLE specimen_ids 
( 
  id         BIGSERIAL NOT NULL, 
  
  specimen_id VARCHAR(512) NOT NULL, 
  project_id  VARCHAR(512) NOT NULL, 
 
  creation_release VARCHAR(512) NOT NULL, 

  PRIMARY KEY(specimen_id, project_id) 
);
CREATE TABLE sample_ids 
( 
  id         BIGSERIAL NOT NULL, 
  
  sample_id  VARCHAR(512) NOT NULL, 
  project_id VARCHAR(512) NOT NULL, 
 
  creation_release VARCHAR(512) NOT NULL, 

  PRIMARY KEY(sample_id, project_id) 
);
CREATE TABLE mutation_ids 
( 
  id         BIGSERIAL NOT NULL, 
  
  chromosome       VARCHAR(512) NOT NULL, 
  chromosome_start VARCHAR(512) NOT NULL, 
  chromosome_end   VARCHAR(512) NOT NULL, 
  mutation_type    VARCHAR(512) NOT NULL, 
  mutation         VARCHAR(512) NOT NULL, 
  assembly_version VARCHAR(512) NOT NULL, 

  creation_release VARCHAR(512) NOT NULL, 
 
  PRIMARY KEY(chromosome, chromosome_start, chromosome_end, mutation_type, mutation, assembly_version) 
);


GRANT SELECT, INSERT ON project_ids TO dcc;
GRANT USAGE, SELECT ON SEQUENCE project_ids_id_seq TO dcc;
GRANT SELECT, INSERT ON donor_ids TO dcc;
GRANT USAGE, SELECT ON SEQUENCE donor_ids_id_seq TO dcc;
GRANT SELECT, INSERT ON sample_ids TO dcc;
GRANT USAGE, SELECT ON SEQUENCE sample_ids_id_seq TO dcc;
GRANT SELECT, INSERT ON specimen_ids TO dcc;
GRANT USAGE, SELECT ON SEQUENCE specimen_ids_id_seq TO dcc;
GRANT SELECT, INSERT ON mutation_ids TO dcc;
GRANT USAGE, SELECT ON SEQUENCE mutation_ids_id_seq TO dcc;

GRANT ALL PRIVILEGES ON DATABASE dcc_identifier to dcc;


