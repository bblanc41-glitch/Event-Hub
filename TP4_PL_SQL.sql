-- TP4 LES DECLANCHEURS

USE parc_info_1;
                /*Question 1 declencheur pour Contrôle de la cohérence des dates*/
DELIMITER $
CREATE TRIGGER Trig_BI_Installer
BEFORE INSERT ON INSTALLER
FOR EACH ROW
BEGIN
    DECLARE v_dateAchat DATETIME;

    -- i1)Recuperation de la date d'achat du logiciel (NLOG) concerne
    SELECT DATEACHAT INTO v_dateAchat 
    FROM LOGICIEL
    WHERE NLOG = NEW.NLOG;

    -- i2)Verification de la condition (Si DATEINS n'est pas NULL, elle doit être > DATEACHAT)
    IF NEW.DATEINS IS NOT NULL AND NEW.DATEINS <= v_dateAchat THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : La date d''installation doit être strictement postérieure à la date d''achat du logiciel.';
    END IF;
END$

DELIMITER ;

-- Question 1.2
ALTER TABLE INSTALLER 
ADD COLUMN trace_User VARCHAR(50) DEFAULT NULL,
ADD COLUMN trace_Date TIMESTAMP DEFAULT NULL;

-- Question 1.3 LES OPPERATION DE MAJ D'UNE COLONNE SONT INSERT, UPDATE & DELETE
-- INSERT
DELIMITER $
CREATE TRIGGER Trig_BI_Installer_Trace -- INSERT
BEFORE INSERT ON INSTALLER
FOR EACH ROW
BEGIN
    -- On modifie directement l'objet NEW avant qu'il ne soit écrit
    SET NEW.trace_User = CURRENT_USER();
    SET NEW.trace_Date = NOW();
END $

-- UPDATE
CREATE TRIGGER Trig_BU_Installer_Trace -- BU pour BEFORE UPDATE
BEFORE UPDATE ON INSTALLER
FOR EACH ROW
BEGIN
    SET NEW.trace_User = CURRENT_USER();
    SET NEW.trace_Date = NOW();
END $

-- test 


-- EXERCICE 2
-- QUESTION 2.1 Deja repondu voir modification.sql (Partie 3:Question 1) & creationDynamique.sql(Partie 5) Pour MAJ automatique

-- QUESTION 2.2 
-- AFTER DELETE(suppression)
-- Pour supprimer il faudrait faire une sauvegarde des ancienes data
-- Creation d'une table de log pour l'operation de suppression
-- 1. Création de la table de log pour les installations supprimees
DELIMITER ;
CREATE TABLE IF NOT EXISTS Log_Installer (
    Log_ID INT AUTO_INCREMENT PRIMARY KEY,
    OperationType VARCHAR(10),
    NPOSTE_Deleted VARCHAR(7),
    NLOG_Deleted VARCHAR(5),
    TraceUser VARCHAR(50),
    TraceDate TIMESTAMP
) ENGINE=InnoDB;


-- Declancheur Apres SUPPRESSION d'une installation
DELIMITER $
CREATE TRIGGER Trig_AD_Installer
AFTER DELETE ON INSTALLER
FOR EACH ROW
BEGIN
    -- Decrementer nbLog du poste
    UPDATE POSTE 
    SET nbLog = nbLog - 1 
    WHERE NPOSTE = OLD.NPOSTE;

    -- decrementer nbInstall du logiciel (Correction du nom de colonne ici)
    UPDATE LOGICIEL 
    SET nbInstall = nbInstall - 1
    WHERE NLOG = OLD.NLOG;

    -- Journalisation
    INSERT INTO Log_Installer (OperationType, NPOSTE_Deleted, NLOG_Deleted, TraceUser, TraceDate)
    VALUES ('DELETE', OLD.NPOSTE, OLD.NLOG, CURRENT_USER(), NOW());
END $

-- Declencheur Apres INSERTION d'une installation
CREATE TRIGGER Trig_AI_Installer
AFTER INSERT ON INSTALLER
FOR EACH ROW
BEGIN
    -- 1. incrementer nbLog du poste
    UPDATE POSTE 
    SET nbLog = nbLog + 1 
    WHERE NPOSTE = NEW.NPOSTE;

    -- 2. incrementer nbInstaller du logiciel
    UPDATE LOGICIEL 
    SET nbInstall = nbInstall + 1 
    WHERE NLOG = NEW.NLOG;
END $

-- QUESTION 2.3 : Synchronisation nbPoste dans SEGMENT (Insertion/Suppression)

-- After insert
-- Metode 1
CREATE TRIGGER Trig_AI_Poste
AFTER INSERT ON POSTE
FOR EACH ROW
BEGIN
    UPDATE SEGMENT S, SALLE SA
    SET S.nbPoste = S.nbPoste + 1
    WHERE S.IndIP = SA.IndIP 
     AND SA.NSALLE = NEW.NSALLE;
END $

-- Apres SUPPRESSION d'un poste (Affter DELETE, IL FAUT DONC PENSER A LA JOURNALISATION)
-- methode 1
CREATE TRIGGER Trig_AD_Poste
AFTER DELETE ON POSTE
FOR EACH ROW
BEGIN
    UPDATE SEGMENT S, SALLE SA
    SET S.nbPoste = S.nbPoste - 1
    WHERE S.IndIP = SA.IndIP 
      AND SA.NSALLE = OLD.NSALLE;

    INSERT INTO Trace (message) 
    VALUES (CONCAT('Suppression poste ', OLD.NPOSTE, ' par ', CURRENT_USER()));
END $

-- QUESTION 2.4 : Synchronisation lors d'un déplacement (UPDATE)
-- Si le poste change de salle ET que les salles sont sur des segments différents

CREATE TRIGGER Trig_AU_Poste
AFTER UPDATE ON POSTE
FOR EACH ROW
BEGIN
    DECLARE v_IndIP_Old VARCHAR(11);
    DECLARE v_IndIP_New VARCHAR(11);

    IF OLD.NSALLE <> NEW.NSALLE THEN
        -- On récupère les segments respectifs
        -- 1. Recuperation de l'IndIP de l'ancienne salle
        SELECT IndIP INTO v_IndIP_Old 
        FROM SALLE 
        WHERE NSALLE = OLD.NSALLE;

        -- 2. Recuperation de l'IndIP de la nouvelle salle
        SELECT IndIP INTO v_IndIP_New 
        FROM SALLE 
        WHERE NSALLE = NEW.NSALLE;

        -- 3. decrementer nbPoste dans l'ANCIEN Segment (si changement de segment)
        IF v_IndIP_Old <> v_IndIP_New THEN
            -- decrementer l'ancien segment
            UPDATE SEGMENT SET nbPoste = nbPoste - 1 
            WHERE IndIP = v_IndIP_Old;
            -- incrementer nbPoste dans le NOUVEAU Segment
            UPDATE SEGMENT SET nbPoste = nbPoste + 1 
            WHERE IndIP = v_IndIP_New;
        END IF;
    END IF;
END $


CREATE TRIGGER Trig_BU_Installer_Trace
BEFORE UPDATE ON INSTALLER
FOR EACH ROW
BEGIN
    SET NEW.trace_User = CURRENT_USER();
    SET NEW.trace_Date = NOW();
END $

DELIMITER ;

-- test 
-- État initial
SELECT IndIP, nbPoste FROM SEGMENT WHERE IndIP IN ('130.120.80', '130.120.81');

-- Question 2.4.1. Insertion (Doit faire +1 sur .80)
INSERT INTO POSTE (NPOSTE, NOMPOSTE, AD, TYPELP, NSALLE) VALUES ('T01', 'Test_Poste', '099', 'T009', 'S01');
SELECT 'Apres Insertion' as Etape, IndIP, nbPoste FROM SEGMENT WHERE IndIP = '130.120.80';


-- Deplacement (Doit faire -1 sur .80 et +1 sur .81)
UPDATE POSTE SET NSALLE = 'S11' WHERE NPOSTE = 'T01';
SELECT 'Apres Déplacement' as Etape, IndIP, nbPoste FROM SEGMENT WHERE IndIP IN ('130.120.80', '130.120.81');

-- Question 2.4. Suppression (Doit faire -1 sur .81)
DELETE FROM POSTE WHERE NPOSTE = 'T01';
SELECT 'Apres Suppression' as Etape, IndIP, nbPoste FROM SEGMENT WHERE IndIP = '130.120.81';


/*
-- Suppression du trigger
DROP TRIGGER IF EXISTS Trig_BI_Installer;
DROP TRIGGER IF EXISTS Trig_BI_Installer_Trace;
DROP TRIGGER IF EXISTS Trig_Ad_Installer_Trace;
DROP TRIGGER IF EXISTS Trig_AD_Installer;
DROP TRIGGER IF EXISTS Trig_AI_Installer;
DROP TRIGGER IF EXISTS Trig_AI_Poste;
DROP TRIGGER IF EXISTS Trig_AD_Poste;
DROP TRIGGER IF EXISTS Trig_AU_Poste;
DROP TRIGGERIF EXISTS Trig_BU_Installer_Trace;

*/