/*PARTIE 4 : CREATION DYNAMIQUES DES DES TABLES AVEC LEURS DONNEES */

/* Rappel de syntaxe de création de tables dynamique avec leur donnees
CREATE TABLE nouveau_nom_de_la_table [options_de_table]
AS SELECT colonne_1 alias1, colonne_2 alias2, ... colonneI aliasI
FROM table_source
[WHERE condition_optionnelle];*/

CREATE TABLE SOFTS
AS SELECT NOMLOG AS nomSotf, VERSION AS version, PRIX
FROM LOGICIEL;

CREATE TABLE PCTerminal
AS SELECT  NPOSTE AS nP, NOMPOSTE AS nomP, AD, NSALLE AS salle, TYPELP AS typeP
FROM POSTE;

/*Verification des tables */
SELECT * FROM SOFTS;
SELECT * FROM PCTERMINAL;

/*PARTIE 5 : MODIFICATION SYNCHRONISEES*/

/* Syntaxe d'une Modifiaction synchronisee
UPDATE table1 alias1
SET colonne= (SELECT *
                FROM table2 alias2
                WHERE alias1.colloneA = alias1.colonneB....);
 */

/*Question 1*/
UPDATE SEGMENT AS S
SET nbSalle = ( SELECT COUNT(*)
    FROM SALLE AS SA
    WHERE SA.IndIP = S.IndIP
);

/*Question 2*/
UPDATE SEGMENT AS S
SET nbPoste = (
    SELECT COUNT(P.NPOSTE)
    FROM POSTE AS P
    JOIN SALLE AS SA ON P.NSALLE = SA.NSALLE
    WHERE SA.IndIP = S.IndIP
);

/* J'ai utilsé la clause join car je l'ai apprise dans mes recherches. 
Ainsi donc la question 2 a pour équivalent :
UPDATE SEGMENT AS S
SET nbPoste = (
    SELECT COUNT(P.NPOSTE)
    FROM POSTE P,SALLE SA
    WHERE P.NSALLE = SA.NSALLE
    AND SA.IndIP = S.IndIP
);*/

/*Question 3*/
UPDATE LOGICIEL L -- L'ensemble des logiciels installés sont dans la table installer
SET nbInstall = (
    SELECT COUNT(*)
    FROM INSTALLER I
    WHERE I.NLOG = L.NLOG
);

/*Question 4*/
UPDATE POSTE P
SET nbLog = (
    SELECT COUNT(*)
    FROM INSTALLER I
    WHERE I.NPOSTE = P.NPOSTE
);

-- Verification des mise à jours automatique
select * from segement;
select * from logiciel;
select * from poste;


/*PARTIE 6 : REQUETES
Ecrire les requêtes permettant d'extraire les données suivantes :
*/

-- PARTIE 6.1 Requêtes avec fonctions et regroupements

/*Question 1. Pour chaque poste, le nombre de logiciels installés (en utilisant la table Installer).*/
SELECT NPOSTE,COUNT(NLOG) AS NbLogiciels
FROM INSTALLER
GROUP BY NPOSTE;

/*Question 2. Pour chaque salle, le nombre de postes (à partir de la table poste).*/
SELECT NSALLE, COUNT(NPOSTE) AS Nombre_Poste
FROM POSTE
GROUP BY NSALLE;

/*Question 3. Pour chaque logiciel, le nombre d'installations sur des postes différents. A revoir*/
SELECT L.NOMLOG, COUNT(I.NPOSTE) AS Nombre_Installations
FROM LOGICIEL L, INSTALLER I
WHERE L.NLOG = I.NLOG
GROUP BY  L.NLOG, L.NOMLOG;

/*Question 4. La date la plus récente d'achat d'un logiciel.*/
SELECT MAX(DATEACHAT) AS DateAchatLaPlusRecente
FROM LOGICIEL;

/*Question 5. Numéros des postes hébergeant 2 logiciels.*/
SELECT NPOSTE
FROM INSTALLER
GROUP BY NPOSTE
HAVING COUNT(DISTINCT NLOG) = 2;

/*Question 6. Nombre de postes hébergeant 2 logiciels (utiliser la requête précédente en faisant un SELECT dans la clause FROM).*/
SELECT COUNT(T.NPOSTE) AS NombreDePostesAvec2Logiciels
FROM ( SELECT NPOSTE
    FROM INSTALLER
    GROUP BY NPOSTE
    HAVING COUNT(DISTINCT NLOG) = 2
) AS T;


/*PARTIE 6.2 Requêtes imbriquées*/

/*Question 1. Types de postes non recensés dans le parc informatique (utiliser la table Types).*/
SELECT T.TYPELP
FROM TYPES T
WHERE T.TYPELP NOT IN(SELECT P.TYPELP
                        FROM POSTE P);
                        
/*Question 2. Types existant à la fois comme types de postes et de logiciels.*/
SELECT TYPELP
FROM TYPES T
WHERE T.TYPELP IN(SELECT P.TYPELP
                        FROM POSTE P)
AND T.TYPELP IN (SELECT L.TYPELP
                        FROM LOGICIEL L);

/*Question 3. Types de postes de travail n'étant pas des types de logiciels.*/
SELECT TYPELP
FROM TYPES T
WHERE T.TYPELP NOT IN (SELECT TYPELP
                            FROM LOGICIEL);

/*Question 4. Adresses IP complètes des postes qui hébergent le logiciel 'L006'. A COMPLETER*/
SELECT CONCAT(S.IndIP,'.', P.AD) AS ADDRESS_IP
FROM SALLE S, POSTE P,INSTALLER I
WHERE S.NSALLE = P.NSALLE
AND P.NPOSTE=I.NPOSTE
AND     I.NLOG ='L006';

/*Question 5. Adresses IP complètes des postes qui hébergent le logiciel de nom 'Oracle Database '.*/
SELECT CONCAT(S.IndIP,'.', P.AD) AS ADDRESS_IP
FROM SALLE S, POSTE P,INSTALLER I
WHERE S.NSALLE = P.NSALLE
AND P.NPOSTE=I.NPOSTE
AND     I.NLOG =(SELECT NLOG FROM LOGICIEL WHERE NOMLOG = 'ORACLE DATABASE');

/*Question 6. Noms des segments possédant exactement trois postes de travail de type 'TX'.*/
SELECT S.NOMSEGMENT
FROM SEGMENT S, SALLE SA, POSTE P, TYPES T -- Ajout de la table TYPES
WHERE S.IndIP = SA.IndIP
    AND SA.NSALLE = P.NSALLE
    AND P.TYPELP = T.TYPELP  -- Jointure avec la table TYPES
    AND T.NOMTYPE LIKE 'TX%' -- Filtrage par nom (commence par 'TX')
GROUP BY  S.NOMSEGMENT
HAVING COUNT(P.NPOSTE) = 3;


/*Question 7. Noms des salles ou l'on peut trouver au moins un poste hébergeant le logiciel 'Oracle Database '.*/

--METHODE 1(avec EXISTS)
SELECT NOMSALLE 
FROM SALLE S WHERE EXISTS(SELECT *
                            FROM POSTE P, INSTALLER I, LOGICIEL L
                            WHERE P.NPOSTE = I.NPOSTE
                            AND I.NLOG = L.NLOG
                            AND L.NOMLOG = 'ORACLE DATABASE'
                            AND S.NSALLE = P.NSALLE);

--METHODE 2(avec IN)
SELECT S.NOMSALLE
FROM SALLE S, POSTE P 
WHERE S.NSALLE = P.NSALLE
AND P.NPOSTE IN (SELECT I.NPOSTE
                    FROM INSTALLER I, LOGICIEL L
                    WHERE I.NLOG =L.NLOG
                    AND L.NOMLOG LIKE 'ORACLE DATABASE');



/*Question 8. Noms des postes ayant au moins un logiciel commun au poste 'P6'.*/
SELECT P1.NOMPOSTE
FROM POSTE P1
WHERE  P1.NPOSTE <> 'P6' -- Exclure P6
    AND EXISTS ( -- Sous-requête corrélée : Existe-t-il un logiciel...
        SELECT 1 -- <=> SELECT *
        FROM INSTALLER I1, INSTALLER Ip6
        WHERE I1.NPOSTE = P1.NPOSTE -- ...installé sur le poste externe...
        AND Ip6.NPOSTE = 'P6'           -- ...et installé sur P6...
        AND I1.NLOG = Ip6.NLOG       -- ...et qui est le même logiciel?
    );

/*Question 9. Noms des postes ayant les mêmes logiciels que le poste 'P6' (les postes peuvent avoir plus d logiciels que 'P6').*/
--Methode 2
select nomposte
From poste p
where not exists (select ins6.nlog From Installer ins6
where ins6.nposte='p6' and ins6.nlog NOT IN (select ins.nlog From Installer ins 
                                                where ins.nposte=p.nposte )
                )and p.nposte!=p.nposte;

--Méthode 1 à verifier car érreur
SELECT P1.NOMPOSTE
FROM POSTE P1
WHERE  P1.NPOSTE <> 'P6' -- Exclure P6
    AND EXISTS ( -- Sous-requête corrélée : Existe-t-il un logiciel...
        SELECT 1 -- <=> SELECT *
        FROM INSTALLER I1, INSTALLER Ip6
        WHERE I1.NPOSTE = P1.NPOSTE -- ...installé sur le poste externe...
        AND Ip6.NPOSTE = 'P6'           -- ...et installé sur P6...
        AND I1.NLOG = Ip6.NLOG       -- ...et qui est le même logiciel?

        AND Ip6.NLOG NOT IN (
            SELECT I1.NLOG
            FROM INSTALLER I1
            WHERE I1.NPOSTE = P1.NPOSTE)
    );
;



/*Question 10. Noms des postes ayant exactement les mêmes logiciels que le poste 'P2'*/
--Methode 1
SELECT  P_ext.NOMPOSTE
FROM  POSTE P_ext
WHERE  P_ext.NPOSTE <> 'P2'
    -- Condition 1: Le poste P_ext a TOUS les logiciels de P2 (via NOT EXISTS)
    AND NOT EXISTS (
        SELECT I_p2.NLOG
        FROM INSTALLER I_p2
        WHERE I_p2.NPOSTE = 'P2'
        AND I_p2.NLOG NOT IN (
            SELECT I_ext.NLOG
            FROM INSTALLER I_ext
            WHERE I_ext.NPOSTE = P_ext.NPOSTE
        )
    )
    -- Condition 2: Le poste P_ext n'a pas de logiciels supplémentaires (vérification du compte)
    AND (
        SELECT COUNT(I_ext.NLOG) -- Compte total des logiciels sur P_ext
        FROM INSTALLER I_ext
        WHERE I_ext.NPOSTE = P_ext.NPOSTE
    ) = (
        SELECT COUNT(I_p2.NLOG) -- Compte total des logiciels sur P2
        FROM INSTALLER I_p2
        WHERE I_p2.NPOSTE = 'P2'
    );


--Methode 2
SELECT nomPoste 
FROM Poste p
 WHERE NOT EXISTS (SELECT i2.nLog FROM Installer i2 WHERE i2.nPoste = 'p2'
AND i2.nLog NOT IN (SELECT i1.nLog FROM Installer i1 WHERE i1.nPoste = p.nPoste))
AND NOT EXISTS (SELECT i1.nLog FROM Installer i1 WHERE i1.nPoste = p.nPoste
AND i1.nLog NOT IN (SELECT i2.nLog FROM Installer i2 WHERE i2.nPoste = 'p2'))
AND NOT (nPoste ='p2');
