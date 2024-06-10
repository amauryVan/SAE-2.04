
-- Création de la table initiale avec la première colonne n1
DROP TABLE IF EXISTS import, Region, Departement, Commune, Academie, Etablissement, Contrat, Formation CASCADE;
DROP VIEW IF EXISTS VoeuxTotaux, EffPropTot;

\echo 'Création de la table import...'
CREATE TABLE import (
    n1 INT
);

-- Boucle pour ajouter les colonnes supplémentaires de n2 à n118 en fonction du type de données
DO $$
DECLARE
    i INT := 2;
BEGIN
    FOR i IN 2..118 LOOP
        -- Création des colonnes n2 à n118
        IF (i > 17 AND i<108 AND i != 102 AND i != 104 AND i != 106) OR i = 110 OR i >= 113 AND i < 117 THEN
            IF (i>=51 AND i<=53) OR i = 66 OR (i >= 74 AND i<=101) OR i = 103 OR (i>=113 AND i<=116) THEN
                EXECUTE 'ALTER TABLE import ADD COLUMN n' || i || ' NUMERIC(6,1)';
            ELSE
                EXECUTE 'ALTER TABLE import ADD COLUMN n' || i || ' INT';
            END IF;  
        ELSE
            EXECUTE 'ALTER TABLE import ADD COLUMN n' || i || ' TEXT';
        END IF;
    END LOOP;
END$$;

\! echo 'Téléchargement des données depuis le site du gouvernement...' && curl https://data.enseignementsup-recherche.gouv.fr/api/explore/v2.1/catalog/datasets/fr-esr-parcoursup/exports/csv > data.csv && echo 'Téléchargement terminé ! '

--Importation des données dans la table
\copy import FROM data.csv with (FORMAT csv, DELIMITER ';', HEADER)
\echo 'Importation des données terminée.'

--Modification des types des colonnes contenant des chaines de caractères, en fonction de la longueur de la plus longue chaine présente dans chaque colonne
DO $$
DECLARE
    i INT;
    max_length INT;
BEGIN
    FOR i IN 2..118 LOOP
        IF (i>=2 AND i<=17) OR i=102 OR i=104 OR i=106 OR i=108 OR i=109 OR i=111 OR i=112 OR i>=117 THEN
            EXECUTE 'SELECT MAX(LENGTH(n' || i || ')) FROM import' INTO max_length;
            EXECUTE 'ALTER TABLE import ALTER COLUMN n' || i || ' TYPE CHAR(' || max_length || ')';
        END IF;
    END LOOP;
END$$;

\echo 'Création de la table Region...'
CREATE TABLE Region (
    rno SERIAL,
    nom_region CHAR(26),
    CONSTRAINT pk_region PRIMARY KEY (rno)
);

\echo 'Insertion des données dans la table Region...'
INSERT INTO Region (nom_region)
    SELECT DISTINCT n7 AS nom_region
    FROM import;


\echo 'Création de la table Departement...'
CREATE TABLE Departement (
    code_departement CHAR(3),
    nom_departement CHAR(23),
    rno INT,
    CONSTRAINT pk_departement PRIMARY KEY (code_departement),
    CONSTRAINT fk_region FOREIGN KEY (rno) REFERENCES Region(rno)
);

\echo 'Insertion des données dans la table Departement...'
INSERT INTO Departement (code_departement, nom_departement, rno)
    SELECT DISTINCT n5 AS code_departement, n6 AS nom_departement, rno
    FROM import JOIN Region 
        ON Region.nom_region = import.n7;

\echo 'Création de la table Commune...'
CREATE TABLE Commune (
    cno SERIAL,
    nom_commune CHAR(29),
    code_departement CHAR(3),
    CONSTRAINT pk_commune PRIMARY KEY (cno),
    CONSTRAINT fk_departement FOREIGN KEY (code_departement) REFERENCES Departement(code_departement)
);

\echo 'Insertion des données dans la table Commune...'
INSERT INTO Commune (nom_commune, code_departement)
    SELECT DISTINCT n9 AS nom_commune, n5 AS code_departement
    FROM import JOIN Departement 
        ON Departement.code_departement = import.n5
    WHERE n9 IS NOT NULL;


\echo 'Création de la table Academie...'
CREATE TABLE Academie (
    ano SERIAL,
    rno INT,
    cno INT,
    CONSTRAINT pk_academie PRIMARY KEY (ano),
    CONSTRAINT fk_region FOREIGN KEY (rno) REFERENCES Region(rno),
    CONSTRAINT fk_commune FOREIGN KEY (cno) REFERENCES Commune(cno)
);

\echo 'Insertion des données dans la table Academie...'
INSERT INTO Academie (rno, cno)
    SELECT DISTINCT rno, cno
    FROM (Departement JOIN Commune ON Departement.code_departement = Commune.code_departement) 
        JOIN import ON import.n8 = Commune.nom_commune AND import.n5 = Departement.code_departement;

\echo 'Création de la table Contrat...'
CREATE TABLE Contrat (
    ctno SERIAL,
    libelle_contrat CHAR(32),
    CONSTRAINT pk_contrat PRIMARY KEY (ctno)
);

\echo 'Insertion des données dans la table Contrat...'
INSERT INTO Contrat (libelle_contrat)
    SELECT DISTINCT n2 AS libelle_contrat
    FROM import;

\echo 'Création de la table Etablissement...'
CREATE TABLE Etablissement (
    code_uai CHAR(8),
    nom_etablissement CHAR(134),
    cno INT,
    ctno INT,
    CONSTRAINT pk_etablissement PRIMARY KEY (code_uai),
    CONSTRAINT fk_contrat FOREIGN KEY (ctno) REFERENCES Contrat(ctno),
    CONSTRAINT fk_commune FOREIGN KEY (cno) REFERENCES Commune(cno) 
);

\echo 'Insertion des données dans la table Etablissement...'
INSERT INTO Etablissement (code_uai, nom_etablissement, cno, ctno)
SELECT DISTINCT n3 AS code_uai, n4 AS nom_etablissement, Commune.cno, Contrat.ctno
FROM import JOIN Commune  ON import.n9 = Commune.nom_commune
            JOIN Contrat ON import.n2 = Contrat.libelle_contrat
ON CONFLICT (code_uai) DO NOTHING;

\echo 'Création de la table Formation...'
CREATE TABLE Formation (
    code_formation INT,
    libelle_formation CHAR(282),
    filiere CHAR(66),
    code_uai CHAR(8),
    capacite_formation INT,
    select_form CHAR(23),
    voeux_total_filles INT,
    nb_bac_generaux_pp INT,
    nb_bac_techno_pp INT,
    nb_bac_pr_pp INT,
    nb_bac_generaux_boursiers_pp INT,
    nb_bac_techno_boursiers_pp INT,
    nb_bac_pro_boursiers_pp INT,
    nb_autres_pp INT,
    nb_bac_generaux_pc INT,
    nb_bac_techno_pc INT,
    nb_bac_pro_pc INT,
    nb_autres_pc INT,
    eff_prop_tot_bg INT,
    eff_prop_tot_bg_boursiers INT,
    eff_prop_tot_bt INT,
    eff_prop_tot_bt_boursiers INT,
    eff_prop_tot_bp INT,
    eff_prop_tot_bp_boursiers INT,
    eff_prop_tot_autres INT,
    total_admis_filles INT,
    total_pp INT,
    total_pc INT,
    total_boursiers INT,
    admis_debut_pp INT,
    admis_date_bac INT,
    admis_fin_pp INT,
    admis_neobac INT,
    admis_bg INT,
    admis_bt INT,
    admis_bp INT,
    admis_autres INT,
    admis_ab INT,
    admis_b INT,
    admis_tb INT,
    CONSTRAINT pk_formation PRIMARY KEY (code_formation),
    CONSTRAINT fk_etablissement FOREIGN KEY (code_uai) REFERENCES Etablissement(code_uai)
);

\echo 'Insertion des données dans la table Formation...'
INSERT INTO Formation
SELECT DISTINCT n110, n10, n14, n3, n18, n11, n20, n23, n25, n27, n24, n26, n28, n29, n31, n32, n33, n34, n95, n96, n97, n98, n99, n100, n101, n48, n49, n50, n55, n51, n52, n53, n56, n57, n58, n59, n60, n63, n64, n65
FROM import
WHERE n9 IS NOT NULL;

CREATE VIEW VoeuxTotaux AS
SELECT code_formation, nb_bac_generaux_pp + nb_bac_techno_pp + nb_bac_pr_pp + nb_autres_pp + nb_bac_generaux_pc + nb_bac_pro_pc + nb_bac_techno_pc + nb_autres_pc  AS Total_voeux FROM formation;

CREATE VIEW EffPropTot AS
SELECT code_formation, eff_prop_tot_bg + eff_prop_tot_bt + eff_prop_tot_bp + eff_prop_tot_autres AS Total_eff_prop FROM formation;

CREATE VIEW EtabOccitanie AS
SELECT code_uai, nom_etablissement, nom_commune, nom_departement, nom_region FROM Etablissement JOIN Commune ON Etablissement.cno = Commune.cno JOIN Departement ON Commune.code_departement = Departement.code_departement JOIN Region ON Departement.rno = Region.rno WHERE Region.nom_region = 'Occitanie';
\echo 'Opérations terminées !'