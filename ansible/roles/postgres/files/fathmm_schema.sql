
DROP TABLE IF EXISTS "DCC_CACHE";
DROP TABLE IF EXISTS "DOMAINS";
DROP TABLE IF EXISTS "LIBRARY";
DROP TABLE IF EXISTS "ONTOLOGIES";
DROP TABLE IF EXISTS "PHENOTYPES";
DROP TABLE IF EXISTS "PROBABILITIES";
DROP TABLE IF EXISTS "PROTEIN";
DROP TABLE IF EXISTS "SEQUENCE";
DROP TABLE IF EXISTS "VARIANTS";
DROP TABLE IF EXISTS "WEIGHTS";



CREATE TYPE phenotypes_origin AS ENUM (
    '0',
    '1'
);



CREATE TYPE weights_type AS ENUM (
    'BLOOD',
    'BLOOD_COAGULATION',
    'CANCER',
    'DEVELOPMENTAL',
    'DIGESTIVE',
    'EAR_NOSE_THROAT',
    'ENDOCRINE',
    'EYE',
    'GENITOURINARY',
    'HEART',
    'IMMUNE',
    'INHERITED',
    'METABOLIC',
    'MUSCULOSKELETAL',
    'NERVOUS_SYSTEM',
    'PSYCHIATRIC',
    'REPRODUCTIVE',
    'RESPIRATORY',
    'SKIN'
);




CREATE TABLE "DCC_CACHE" (
    translation_id character varying(64) NOT NULL,
    aa_mutation character varying(64) NOT NULL,
    score character varying(16),
    prediction character varying(16)
);


CREATE TABLE "DOMAINS" (
    id integer NOT NULL,
    hmm character(15) NOT NULL,
    score double precision NOT NULL,
    seq_begin integer NOT NULL,
    seq_end integer NOT NULL,
    hmm_begin integer NOT NULL,
    align text NOT NULL
);


CREATE TABLE "LIBRARY" (
    id character(15) NOT NULL,
    accession character(30) NOT NULL,
    description text
);

CREATE TABLE "ONTOLOGIES" (
    id character(2) NOT NULL,
    description text NOT NULL
);


CREATE TABLE "PHENOTYPES" (
    id character(30) NOT NULL,
    type character(2) NOT NULL,
    accession character(30) NOT NULL,
    description character(150) NOT NULL,
    score double precision NOT NULL,
    origin phenotypes_origin NOT NULL
);


CREATE TABLE "PROBABILITIES" (
    id character(15) NOT NULL,
    "position" integer NOT NULL,
    "A" double precision NOT NULL,
    "C" double precision NOT NULL,
    "D" double precision NOT NULL,
    "E" double precision NOT NULL,
    "F" double precision NOT NULL,
    "G" double precision NOT NULL,
    "H" double precision NOT NULL,
    "I" double precision NOT NULL,
    "K" double precision NOT NULL,
    "L" double precision NOT NULL,
    "M" double precision NOT NULL,
    "N" double precision NOT NULL,
    "P" double precision NOT NULL,
    "Q" double precision NOT NULL,
    "R" double precision NOT NULL,
    "S" double precision NOT NULL,
    "T" double precision NOT NULL,
    "V" double precision NOT NULL,
    "W" double precision NOT NULL,
    "Y" double precision NOT NULL,
    information double precision NOT NULL
);


CREATE TABLE "PROTEIN" (
    id integer NOT NULL,
    name character(100) NOT NULL
);


CREATE TABLE "SEQUENCE" (
    id integer NOT NULL,
    sequence text NOT NULL
);


CREATE TABLE "VARIANTS" (
    id character(25) NOT NULL,
    protein character(100) NOT NULL,
    substitution character(10) NOT NULL
);


CREATE TABLE "WEIGHTS" (
    id character(15) NOT NULL,
    type weights_type NOT NULL,
    disease double precision NOT NULL,
    other double precision NOT NULL
);


ALTER TABLE ONLY "LIBRARY"
    ADD CONSTRAINT "LIBRARY_pkey" PRIMARY KEY (id);


ALTER TABLE ONLY "ONTOLOGIES"
    ADD CONSTRAINT "ONTOLOGIES_pkey" PRIMARY KEY (id);


ALTER TABLE ONLY "PROBABILITIES"
    ADD CONSTRAINT "PROBABILITIES_pkey" PRIMARY KEY (id, "position");


ALTER TABLE ONLY "PROTEIN"
    ADD CONSTRAINT "PROTEIN_pkey" PRIMARY KEY (name);


ALTER TABLE ONLY "SEQUENCE"
    ADD CONSTRAINT "SEQUENCE_pkey" PRIMARY KEY (id);


ALTER TABLE ONLY "WEIGHTS"
    ADD CONSTRAINT "WEIGHTS_pkey" PRIMARY KEY (id, type);



CREATE INDEX c1 ON "DCC_CACHE" USING btree (translation_id, aa_mutation);
CREATE INDEX i1 ON "DOMAINS" USING btree (id);
CREATE INDEX i2 ON "DOMAINS" USING btree (hmm);


GRANT SELECT, INSERT on "DCC_CACHE" TO dcc;
GRANT SELECT, INSERT on "DOMAINS" TO dcc;
GRANT SELECT, INSERT on "LIBRARY" TO dcc;
GRANT SELECT, INSERT on "ONTOLOGIES" TO dcc;
GRANT SELECT, INSERT on "PHENOTYPES" TO dcc;
GRANT SELECT, INSERT on "PROBABILITIES" TO dcc;
GRANT SELECT, INSERT on "PROTEIN" TO dcc;
GRANT SELECT, INSERT on "SEQUENCE" TO dcc;
GRANT SELECT, INSERT on "VARIANTS" TO dcc;
GRANT SELECT, INSERT on "WEIGHTS" TO dcc;


GRANT ALL PRIVILEGES ON DATABASE fathmm to dcc;

