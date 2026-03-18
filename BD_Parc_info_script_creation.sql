/*======================== PARTIE 1 ========================*/

/*Question 1: CREATION DE LA BASE DE DONNEES*/

CREATE DATABASE parc_info_1;
USE parc_info_1;

/*==============================================================*/
/* Table : SEGMENT                                              */
/*==============================================================*/
create table SEGMENT
(
   IndIP                 varchar(11) not null  comment '',
   NOMSEGMENT           varchar(20)  not null comment '',
   ETAGE                smallint  comment '',
   primary key (IndIP)
)ENGINE=InnoDB;

/*==============================================================*/
/* Table : TYPE                                                 */
/*==============================================================*/
create table TYPES
(
   TYPELP               varchar(10) not null  comment '',
   NOMTYPE              varchar(20)  comment '',
   CATEGORIE            varchar(55)  comment '',
   primary key (TYPELP)
)ENGINE=InnoDB;

/*==============================================================*/
/* Table : SALLE                                                */
/*==============================================================*/
create table SALLE
(
   NSALLE               varchar(7) not null  comment '',
   NOMSALLE             varchar(20)  not null comment '',
   INDIP                 varchar(11) not null  comment '',
   primary key (NSALLE)
)ENGINE=InnoDB;

/*==============================================================*/
/* Table : POSTE                                                */
/*==============================================================*/
create table POSTE
(
   NPOSTE               varchar(7) not null  comment '',
   NOMPOSTE             varchar(20) not null comment '',
   AD                   VARCHAR(3) CHECK(AD BETWEEN '000' AND '255') COMMENT '',  -- 
   TYPELP               varchar(10) not null  comment '',
   NSALLE               varchar(7) not null  comment '',
   primary key (NPOSTE)
)ENGINE=InnoDB;

/*==============================================================*/
/* Table : LOGICIEL                                             */
/*==============================================================*/
create table LOGICIEL
(
   NLOG                 varchar(5) not null  comment '',
   NOMLOG               varchar(30)  comment '',
   DATEACHAT            datetime  comment '',
   VERSION              char(10)  comment '',
   TYPELP               varchar(10) not null  comment '',
   PRIX                 decimal(6,2) check(PRIX >='0') comment '',  -- 
   primary key (NLOG)
)ENGINE=InnoDB;



/*==============================================================*/
/* Table : INSTALLER                                            */
/*==============================================================*/
create table INSTALLER
(
   NUMINS               int not null  comment '',
   NPOSTE               varchar(7) not null  comment '',
   NLOG                 varchar(5) not null  comment '',
   DATEINS              timestamp default now() comment '',
   DELAI                smallint  comment '',
   primary key (NUMINS)
)ENGINE=InnoDB;


--   Ajout des contraintes d'intégrité

alter table INSTALLER add constraint FK_INSTALLE_CONCERNE_LOGICIEL foreign key (NLOG)
      references LOGICIEL (NLOG) on delete restrict on update restrict;

alter table INSTALLER add constraint FK_INSTALLE_CONCERNER_POSTE foreign key (NPOSTE)
      references POSTE (NPOSTE) on delete restrict on update restrict;

alter table LOGICIEL add constraint FK_LOGICIEL_CLASSER_TYPE foreign key (TYPELP)
      references TYPES (TYPELP) on delete restrict on update restrict;

alter table POSTE add constraint FK_POSTE_CLASSE_TYPE foreign key (TYPELP)
      references TYPES (TYPELP) on delete restrict on update restrict;

alter table POSTE add constraint FK_POSTE_CONTENIR_SALLE foreign key (NSALLE)
      references SALLE (NSALLE) on delete restrict on update restrict;

alter table SALLE add constraint FK_SALLE_SITUER_SEGMENT foreign key (IndIP)
      references SEGMENT (IndIP) on delete restrict on update restrict;

ALTER TABLE TYPES MODIFY COLUMN  NOMTYPE VARCHAR(55);

ALTER TABLE LOGICIEL
MODIFY COLUMN PRIX DECIMAL(8,2) CHECK(PRIX >= 0);

