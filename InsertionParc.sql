/* Aliment tation de la BD du Parc_info

Rappel_d'insertion:
INSERT INTO NomDeLaTable (colonne1, colonne2, ..., colonneN)
(valeur1, valeur2, ..., valeurN);
*/

/*PARTIE 1 (SUITE)*/

/*Question 2: SCRIPT D'INSERTION DES DONNEES*/

/*INSERTION DANS LA TABLE Segment */
INSERT INTO SEGMENT
VALUES('130.120.80',"Brin RDC",0),
('130.120.81',"Brin 1er étage",1),
('130.120.82',"Brin 2er étage",2),
('130.120.83',"Brin 3eme étage",3),
('130.120.84',"Brin 4eme étage",4);

/*INSERTION DANS LA TABLE  Types */
INSERT INTO TYPES
VALUES('T001',"Base de données","Logiciel"),
('T002',"Business Intelligence(BI)","Logiciel"),
('T003',"ERP (Planification des ressources","Logiciel"),
('T004',"Cloud / Infrastructure","Logiciel"),
('T005',"Statistiques / Data Science","Logiciel"),
('T006',"Virtualisation Serveurs","Logiciel"),
('T007',"Gestion de projet Logiciel T008 UNIX","Logiciel"),
('T008',"UNIX","Logiciel"),
('T009',"TX (Terminal X)","Poste de travail"),-- T011=>T009
('T010',"macOS","Poste de travail"),-- T012=> T010
('T013',"Mainframe IBM Z","Poste de travail"), 
('T014',"Virtual Desktop (VDI)","Poste de travail"),
('T015',"Android Work Profile","Poste de travail"); -- T016=>T015


/*INSERTION DANS LA TABLE Salle */
INSERT INTO  SALLE
VALUES('S01',"Salle 1",'130.120.80'),
('S02',"Salle 2",'130.120.80'),
('S03',"Salle 3",'130.120.80'),
('S11',"Salle 11",'130.120.81'),
('S12',"Salle 12",'130.120.81'),
('S21',"Salle 21",'130.120.82'),
('S22',"Salle 22",'130.120.83'),
('S23',"Salle 23",'130.120.83');


/*INSERTION DANS LA TABLE Poste */
INSERT INTO Poste
VALUES('P1','Poste1','01','T009','S01'),
('P2','Poste2','02','T010','S01'),
('P3','Poste3','03','T009','S01'),
('P4','Poste4','04','T013','S02'),
('P5','Poste5','05','T009','S02'),
('P6','Poste6','06','T010','S03'),
('P7','Poste7','07','T014','S03'),
('P8','Poste8','01','T015','S11'),
('P9','Poste9','02','T009','S11'),
('P10','Poste10','03','T013','S12'),
('P11','Poste11','01','T009','S21'),
('P12','Poste12','02','T015','S21');

/*INSERTION DANS LA TABLE Logiciel */
INSERT INTO Logiciel 
VALUES('L001',"Oracle Database",'2022-07-15','19c','T001',25000),
('L002',"Power BI",'2023-01-20','3.0','T002',1200),
('L003',"SAP ERP",'2021-11-05','7.4','T003',48000),
('L004',"AWS CLI",'2023-05-10','2.5','T004',0),
('L005',"R Studio",'2022-08-18','4.2.1','T005',0),
('L006',"VMware ESXi",'2022-12-01','7.0','T006',1500),
('L007',"Jira",'2023-03-12','9.5','T007',1000),
('L008',"Solaris UNIX",'2021-06-23','11.4','T008',2000),
('L009',"Windows Server 2019",'2022-04-30','2019','T009',4000),
('L010',"Ubuntu Linux 20.04",'2023-02-15','20.04','T010',0),
('L011',"Docker Desktop",'2023-07-01','4.17','T015',0);

/* INSERTION DANS LA TABLE INSTALLER */
INSERT INTO INSTALLER
VALUES(1,"P2","L001",'2022-07-19',NULL),
(2,"P2","L002",'2023-01-25',NULL),
(3,"P4","L005",'2022-08-20',NULL),
(4,"P6","L006",'2024-12-01',NULL),
(5,"P6","L001",'2022-07-10',NULL),
(6,"P8","L002",'2023-06-20',NULL),
(7,"P8","L006",'2022-11-01',NULL),
(8,"P8","L001",'2021-12-05',NULL),
(9,"P12","L001",'2024-07-10',NULL),
(10,"P12","L002",'2023-04-23',NULL),
(11,"P7","L007",'2023-02-12',NULL);
