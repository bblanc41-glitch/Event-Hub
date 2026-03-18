--TP3_PL_SQL
USE parc_info_1;
/*QUESTION 1.1 Ecrire une fonction FCT_poste_valeur qui permet de calculer la somme des prix des logiciels 
installés sur un poste. La procédure prend comme paramètre le numéro de poste (nPoste). */

SET GLOBAL log_bin_trust_function_creators = 1$ --INDISPENSABLE SINON ERREUR

DELIMITER $ -- INUTILE APRES SET GLOBAL ??
CREATE FUNCTION FCT_poste_valeure(nPoste VARCHAR(7)) RETURNS DECIMAL(8,2)
READS SQL DATA
BEGIN 
DECLARE SOMME DECIMAL(8,2);
SELECT SUM(Lo.PRIX) INTO SOMME
            FROM POSTE Pos, LOGICIEL Lo, INSTALLER Insta
            WHERE Pos.NPOSTE = Insta.NPOSTE
            AND Insta.NLOG  = Lo.NLOG;
    IF SOMME IS NULL THEN-- SI PRIX NON RENSEIGNE (NULL)
        SET SOMME=0.00;
    END IF;
RETURN SOMME;
END;
$

SELECT FCT_poste_valeure('P2')$ -- appel de la fonction stockee

/*Verifiaction de la creation des fonction stockée*/
SELECT ROUTINE_NAME, ROUTINE_TYPE
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'parc_info_1';

/*Supression des fonctions & procedeures stockées*/
DROP PROCEDURE IF EXISTS nom_procedure;
DROP FUNCTION IF EXISTS nom_fonction;



/*QUESTION 1.2 Ecrire une procédure pro_detail qui permet d’afficher pour une salle donnée, le nombre de postes et 
la liste des logiciels installés. La procédure prend comme paramètre le numéro de la salle. */

--Methode 1
DELIMITER $
DROP PROCEDURE IF EXISTS pro_detail;
$

DELIMITER $
CREATE PROCEDURE pro_detail (p_nSalle VARCHAR(7))
READS SQL DATA
BEGIN
    /* RESPECT OBLIGATOIRE DE L'ODRE SUIVANT: 
    DECLARATION DES VARIABLES
    DECLARATION DU CURSUER PUIS DU HANDLER (TRES IMPORTANT SINON ERREUR)
    AJOUT DU CODE EXECUTABLE*/
    DECLARE v_nb_postes INT; -- nbre de poste
    DECLARE v_done INT DEFAULT FALSE; -- Curseeur
    
    -- Variables pour récupérer les données du curseur (infos du poste)
    DECLARE v_nPoste VARCHAR(7);
    DECLARE v_nomPoste VARCHAR(20);

    -- 1. declaration du curseur pour parcourir chaque poste de la salle
    DECLARE cur_postes CURSOR FOR
        SELECT NPOSTE, NOMPOSTE
        FROM POSTE
        WHERE NSALLE = p_nSalle;

    -- declaration du handler pour la fin du curseur
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- 2. Calcul et affichage du nombre total de postes dans la salle
    SELECT COUNT(NPOSTE) INTO v_nb_postes
    FROM POSTE
    WHERE NSALLE = p_nSalle;

    SELECT CONCAT('Salle ', p_nSalle, ' ( Total Postes : ', v_nb_postes, ')') AS Information_Salle;

    OPEN cur_postes;-- Ouverture du curseur

    read_loop: LOOP-- Boucle de parcours des postes
        FETCH cur_postes INTO v_nPoste, v_nomPoste;-- Curseur sur les variables npost et nomposte 
                            -- il faut respecter l'ordre des variables du curseur
        IF v_done THEN -- somme-nous arrive a la fin ? Oui si v_done = TRUE et Non sinon
            LEAVE read_loop; -- sortie de la boucle si v_done= TRUE
        END IF;
        
        -- Afficher un sms pour chaque poste(sms de separation)
        SELECT CONCAT('-> Détail des logiciels sur Poste : ', v_nomPoste, ' (', v_nPoste, ')') AS Poste_Actuel;
        
        -- Recuperation et affichage des logiciels pour le poste actuel
        SELECT L.NOMLOG AS Nom_Logiciel,L.VERSION AS Version,I.DATEINS AS Date_Installation
        FROM INSTALLER I, LOGICIEL L
        WHERE I.NLOG = L.NLOG
          AND I.NPOSTE = v_nPoste -- jointure avec la table poste via la variable du curseur v_nPoste qui contient(pointe sur) le NPOSTE de la table POSTE
        ORDER BY L.NOMLOG;
    END LOOP;
    CLOSE cur_postes; -- Fermeture du curseur
END $

CALL pro_detail('S12')$ -- appel de la procedure



/*                           Exercice 2                           */
CREATE TABLE IF NOT EXISTS Trace (
    message VARCHAR(80)
)ENGINE=InnoDB;

/*METHODE 1*/
DELIMITER $
CREATE PROCEDURE pro_calcul_delai_installation ()
MODIFIES SQL DATA
BEGIN
    -- 1. Déclarations des variables
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_nPoste VARCHAR(7);
    DECLARE v_nLog VARCHAR(5);
    DECLARE v_dateIns TIMESTAMP;
    DECLARE v_dateAchat DATETIME;
    DECLARE v_nomLog VARCHAR(30);
    DECLARE v_nomPoste VARCHAR(20);
    DECLARE v_delai INT;
    DECLARE v_message VARCHAR(80);
    
    -- 2. Déclaration du curseur (après les variables)
    DECLARE cur_installations CURSOR FOR
        SELECT I.NPOSTE, I.NLOG, I.DATEINS, L.DATEACHAT, L.NOMLOG, P.NOMPOSTE
        FROM INSTALLER I, LOGICIEL L, POSTE P -- Jointure implicite pour récupérer toutes les infos nécessaires
        WHERE I.NLOG = L.NLOG
          AND I.NPOSTE = P.NPOSTE;

    -- 3. Déclaration du handler ( après les variables ET le curseur)
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    -- Vider la table Trace avant exécution pour ne garder que les résultats de l'appel courant
    DELETE FROM Trace; 


    -- 4. Code exécutable
    
    OPEN cur_installations;

    read_loop: LOOP
        FETCH cur_installations INTO v_nPoste, v_nLog, v_dateIns, v_dateAchat, v_nomLog, v_nomPoste;
        
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        -- Réinitialiser les variables de la boucle pour un traitement propre
        SET v_delai = NULL;
        SET v_message = NULL;

        -- Verification des incoherences (date d'installation ou d'achat inconnue) 
        IF v_dateAchat IS NULL THEN
            SET v_message = CONCAT('Date d''achat inconnue pour le logiciel ', v_nomLog, ' sur Poste ', v_nPoste, '!'); 
        ELSEIF v_dateIns IS NULL THEN
            SET v_message = CONCAT('Date d''installation inconnue pour le logiciel ', v_nomLog, ' sur Poste ', v_nPoste, '!');
        ELSE
            -- Calcul du nombre entier de jours séparant l'achat de l'installation
            SET v_delai = DATEDIFF(v_dateIns, v_dateAchat);

            IF v_delai >= 0 THEN
                -- Cas normal : Installation après l'achat (attente) 
                SET v_message = CONCAT('Logiciel ', v_nomLog, ' sur Poste ', v_nPoste, ' attente ', v_delai, ' jour(s).');
                
                -- Mise à jour de la colonne DELAI 
                UPDATE INSTALLER
                SET DELAI = v_delai
                WHERE NPOSTE = v_nPoste AND NLOG = v_nLog;

            ELSE
                -- Cas d'incohérence : Installation avant l'achat 
                SET v_message = CONCAT('Logiciel ', v_nomLog, ' installé sur Poste ', v_nPoste, ' ', ABS(v_delai), ' jour(s) avant l''achat!');
                -- DELAI n'est pas mis à jour (reste NULL) pour l'incohérence
            END IF;
        END IF;

        -- Insérer le message dans la table Trace si un message a été généré 
        IF v_message IS NOT NULL THEN
            INSERT INTO Trace (message) VALUES (v_message);
        END IF;

    END LOOP;

    CLOSE cur_installations;

    -- Afficher le contenu de la table Trace en fin de procédure
    SELECT '--- Rapport de l''operation (Table Trace) ---' AS Statut;
    SELECT message 
    FROM Trace;
END $

CALL pro_calcul_delai_installation();-- Pour exécuter :

SELECT * FROM INSTALLER; -- Verifiaction des MAJ de la colonne delai de la table INSTALLER

