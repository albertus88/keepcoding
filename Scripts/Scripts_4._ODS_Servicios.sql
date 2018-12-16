# SERVICIOS
# CREACIÓN DE TABLAS
USE ODS;

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS ODS_DM_CANALES;

CREATE TABLE ODS_DM_CANALES
(ID_CANAL INT(10) AUTO_INCREMENT PRIMARY KEY
, DE_CANAL VARCHAR(512)
, FC_INSERT DATETIME
, FC_MODIFICACION DATETIME);

DROP TABLE IF EXISTS ODS_DM_PRODUCTOS;

CREATE TABLE ODS_DM_PRODUCTOS
(ID_PRODUCTO INT(10) AUTO_INCREMENT PRIMARY KEY
, DE_PRODUCTO VARCHAR(512)
, FC_INSERT DATETIME
, FC_MODIFICACION DATETIME);

DROP TABLE IF EXISTS ODS_HC_SERVICIOS;

CREATE TABLE ODS_HC_SERVICIOS
(ID_SERVICIO INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY
, REF_PRODUCTO INT(10)
, ID_CLIENTE INT(11)
, ID_PRODUCTO INT(10)
, PUNTO_ACCESO VARCHAR(512)
, ID_CANAL INT(10)
, ID_AGENTE INT(11)
, FC_INICIO DATETIME
, FC_INSTALACION DATETIME
, FC_FIN DATETIME
, ID_DIRECCION_SERVICIO INT(10) UNSIGNED
, FC_INSERT DATETIME
, FC_MODIFICACION DATETIME);

# CREACIÓN DE FK

ALTER TABLE ODS_HC_SERVICIOS ADD INDEX fk_cli_ser_idx (ID_CLIENTE ASC);
ALTER TABLE ODS_HC_SERVICIOS ADD CONSTRAINT fk_cli_ser FOREIGN KEY (ID_CLIENTE)
     REFERENCES ODS_HC_CLIENTES(ID_CLIENTE);
     
ALTER TABLE ODS_HC_SERVICIOS ADD INDEX fk_pro_ser_idx (ID_PRODUCTO ASC);
ALTER TABLE ODS_HC_SERVICIOS ADD CONSTRAINT fk_pro_ser FOREIGN KEY (ID_PRODUCTO)
     REFERENCES ODS_DM_PRODUCTOS(ID_PRODUCTO);

ALTER TABLE ODS_HC_SERVICIOS ADD INDEX fk_can_ser_idx (ID_CANAL ASC);
ALTER TABLE ODS_HC_SERVICIOS ADD CONSTRAINT fk_can_ser FOREIGN KEY (ID_CANAL)
     REFERENCES ODS_DM_CANALES(ID_CANAL);

ALTER TABLE ODS_HC_SERVICIOS ADD INDEX fk_dir_ser_idx (ID_DIRECCION_SERVICIO ASC);
ALTER TABLE ODS_HC_SERVICIOS ADD CONSTRAINT fk_dir_ser FOREIGN KEY (ID_DIRECCION_SERVICIO)
     REFERENCES ODS_HC_DIRECCIONES(ID_DIRECCION);

# POBLAMOS EL MODELO

INSERT INTO ODS_DM_CANALES (DE_CANAL, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(CHANNEL)) CANAL
, NOW(),NOW()
FROM STAGE.STG_PRODUCTOS_CRM PROD
WHERE TRIM(CHANNEL)<>'';
INSERT INTO ODS_DM_CANALES VALUES (9999,'DESCONOCIDO', NOW(),NOW());
INSERT INTO ODS_DM_CANALES VALUES (9998,'NO APLICA', NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_CANALES;

INSERT INTO ODS_DM_PRODUCTOS (DE_PRODUCTO, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(PRODUCT_NAME)) PRODUCTO
, NOW(),NOW()
FROM STAGE.STG_PRODUCTOS_CRM PROD
WHERE TRIM(PRODUCT_NAME)<>'';
INSERT INTO ODS_DM_PRODUCTOS VALUES (9999,'DESCONOCIDO', NOW(),NOW());
INSERT INTO ODS_DM_PRODUCTOS VALUES (9998,'NO APLICA', NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_PRODUCTOS;

DROP TRIGGER IF EXISTS trigger_paises;

CREATE TRIGGER trigger_paises BEFORE INSERT ON ODS.ODS_DM_PAISES
FOR EACH ROW SET NEW.ID_PAIS=(SELECT MAX(ID_PAIS)+1
								FROM ODS_DM_PAISES
								WHERE ID_PAIS NOT IN (98,99));
                                
INSERT INTO ODS_DM_PAISES (DE_PAIS, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT CASE WHEN UPPER(TRIM(PRODUCT_COUNTRY))='UNITED STATES' THEN 'US'
						ELSE UPPER(TRIM(PRODUCT_COUNTRY)) END AS DE_PAIS
, NOW()
, NOW()
FROM STAGE.STG_PRODUCTOS_CRM PROD
LEFT OUTER JOIN ODS.ODS_DM_PAISES PAI ON
		CASE WHEN UPPER(TRIM(PRODUCT_COUNTRY))='UNITED STATES' THEN 'US'
			ELSE UPPER(TRIM(PRODUCT_COUNTRY)) END=PAI.DE_PAIS
WHERE TRIM(PRODUCT_COUNTRY)<>''
AND PAI.DE_PAIS IS NULL;

COMMIT;

DROP TRIGGER IF EXISTS trigger_ciudades_estados;

CREATE TRIGGER trigger_ciudades_estados BEFORE INSERT ON ODS.ODS_DM_CIUDADES_ESTADOS
FOR EACH ROW SET NEW.ID_CIUDAD_ESTADO=(SELECT MAX(ID_CIUDAD_ESTADO)+1
								FROM ODS_DM_CIUDADES_ESTADOS
								WHERE ID_CIUDAD_ESTADO NOT IN (998,999));
                                
INSERT INTO ODS_DM_CIUDADES_ESTADOS (DE_CIUDAD, DE_ESTADO, ID_PAIS, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT CASE WHEN TRIM(PRODUCT_CITY)<>'' THEN UPPER(TRIM(PROD.PRODUCT_CITY))
					ELSE 'DESCONOCIDO' END CIUDAD
, CASE WHEN TRIM(PROD.PRODUCT_STATE)<>'' THEN UPPER(TRIM(PROD.PRODUCT_STATE))
		ELSE 'DESCONOCIDO' END ESTADO
, PAI.ID_PAIS
, NOW(), NOW()
FROM STAGE.STG_PRODUCTOS_CRM PROD
INNER JOIN ODS.ODS_DM_PAISES PAI ON CASE WHEN TRIM(PROD.PRODUCT_COUNTRY)<>'' THEN
			CASE WHEN UPPER(TRIM(PROD.PRODUCT_COUNTRY))='UNITED STATES' THEN 'US'
				ELSE UPPER(TRIM(PROD.PRODUCT_COUNTRY)) END
			ELSE 'DESCONOCIDO' END=PAI.DE_PAIS
LEFT OUTER JOIN ODS_DM_CIUDADES_ESTADOS
	ON CONCAT(TRIM(PROD.PRODUCT_CITY),'#',TRIM(PROD.PRODUCT_STATE))=concat(DE_CIUDAD,'#',DE_ESTADO)
WHERE concat(DE_CIUDAD,'#',DE_ESTADO) IS NULL;

COMMIT;

/*AÑADIMOS NUEVAS DIRECCIONES EN TABLA DIRECCIONES)*/
CREATE TABLE TMP_DIRECCION AS (
SELECT DISTINCT UPPER(TRIM(SSPC.PRODUCT_ADDRESS)) DIRECCION
, CASE WHEN LENGTH((SSPC.PRODUCT_POSTAL_CODE))<>0 THEN UPPER(TRIM(SSPC.PRODUCT_POSTAL_CODE)) ELSE 999 END CP
, OODCE.ID_CIUDAD_ESTADO CIUDAD_ESTADO
FROM STAGE.STG_PRODUCTOS_CRM SSPC
JOIN ODS_DM_CIUDADES_ESTADOS OODCE ON CASE WHEN LENGTH(TRIM(SSPC.PRODUCT_CITY))<>0 THEN SSPC.PRODUCT_CITY ELSE 'DESCONOCIDO' END=OODCE.DE_CIUDAD
									AND CASE WHEN LENGTH(TRIM(SSPC.PRODUCT_STATE))<>0 THEN SSPC.PRODUCT_STATE ELSE 'DESCONOCIDO' END=OODCE.DE_ESTADO
WHERE TRIM(SSPC.PRODUCT_ADDRESS)<>''
);

INSERT INTO TMP_DIRECCION SELECT DE_DIRECCION, DE_CP , ID_CIUDAD_ESTADO FROM ODS.ODS_HC_DIRECCIONES;

ANALYZE TABLE TMP_DIRECCION;

CREATE TABLE TMP2_DIRECCION AS 
(SELECT DIRECCION DIRECCION, CP CP, CIUDAD_ESTADO CIUDAD_ESTADO 
FROM TMP_DIRECCION
GROUP BY DIRECCION, CP, CIUDAD_ESTADO  
HAVING COUNT(CIUDAD_ESTADO)=1);

ANALYZE TABLE TMP2_DIRECCION;

INSERT INTO ODS.ODS_HC_DIRECCIONES (DE_DIRECCION, DE_CP , ID_CIUDAD_ESTADO, FC_INSERT, FC_MODIFICACION)
SELECT *, NOW(), NOW()
FROM TMP2_DIRECCION;

DROP TABLE IF EXISTS TMP_DIRECCION;
DROP TABLE IF EXISTS TMP2_DIRECCION;

/*POBLAMOS SERVICIOS*/

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES;

CREATE TABLE TMP_DIRECCIONES_CLIENTES AS
SELECT DIR.ID_DIRECCION
, DIR.DE_DIRECCION
, DIR.DE_CP
, CIU.DE_CIUDAD
, CIU.DE_ESTADO
, PAI.DE_PAIS
FROM ODS.ODS_HC_DIRECCIONES DIR
INNER JOIN ODS.ODS_DM_CIUDADES_ESTADOS CIU ON DIR.ID_CIUDAD_ESTADO=CIU.ID_CIUDAD_ESTADO
INNER JOIN ODS.ODS_DM_PAISES PAI ON CIU.ID_PAIS=PAI.ID_PAIS;

ANALYZE TABLE TMP_DIRECCIONES_CLIENTES;

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES2;

CREATE TABLE TMP_DIRECCIONES_CLIENTES2 AS
SELECT PRODUCTOS.PRODUCT_ID
, DIR.ID_DIRECCION
FROM STAGE.STG_PRODUCTOS_CRM PRODUCTOS
INNER JOIN ODS.TMP_DIRECCIONES_CLIENTES DIR ON CASE WHEN TRIM(PRODUCT_ADDRESS)<>'' THEN UPPER(TRIM(PRODUCT_ADDRESS)) ELSE 'DESCONOCIDO' END=DIR.DE_DIRECCION
											AND CASE WHEN TRIM(PRODUCT_POSTAL_CODE)<>'' THEN UPPER(TRIM(PRODUCT_POSTAL_CODE)) ELSE 99999 END=DIR.DE_CP
											AND	CASE WHEN TRIM(PRODUCT_CITY)<>'' THEN UPPER(TRIM(PRODUCT_CITY)) ELSE 'DESCONOCIDO' END=DIR.DE_CIUDAD
											AND CASE WHEN TRIM(PRODUCT_STATE)<>'' THEN UPPER(TRIM(PRODUCT_STATE)) ELSE 'DESCONOCIDO' END=DIR.DE_ESTADO
											AND CASE WHEN TRIM(PRODUCT_COUNTRY)<>'' THEN 'US' ELSE 'DESCONOCIDO' END=DIR.DE_PAIS;
										
ANALYZE TABLE TMP_DIRECCIONES_CLIENTES2;

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES3;

CREATE TABLE TMP_DIRECCIONES_CLIENTES3 AS
SELECT PRODUCT_ID
, MIN(ID_DIRECCION) ID_DIRECCION
FROM TMP_DIRECCIONES_CLIENTES2
GROUP BY PRODUCT_ID;

ANALYZE TABLE TMP_DIRECCIONES_CLIENTES3;

INSERT INTO ODS_HC_SERVICIOS
(ID_SERVICIO,
ID_CLIENTE
,ID_PRODUCTO
,PUNTO_ACCESO
,ID_CANAL
,ID_AGENTE
,ID_DIRECCION_SERVICIO
,FC_INICIO
,FC_INSTALACION
,FC_FIN
,FC_INSERT
,FC_MODIFICACION)
SELECT SSPC.PRODUCT_ID
, OOHC.ID_CLIENTE
, OODP.ID_PRODUCTO
, CASE WHEN TRIM(SSPC.ACCESS_POINT)<>'' THEN TRIM(UPPER(SSPC.ACCESS_POINT)) ELSE 'DESCONOCIDO' END PUNTO_ACCESO
, OODC.ID_CANAL
, CASE WHEN TRIM(TDC.ID_DIRECCION)<>'' THEN TDC.ID_DIRECCION ELSE 999999 END ID_DIRECCION
, CASE WHEN TRIM(SSPC.AGENT_CODE)<>'' THEN TRIM(UPPER(SSPC.AGENT_CODE)) ELSE '000' END ID_AGENTE
, CASE WHEN TRIM(SSPC.START_DATE)<>'' THEN STR_TO_DATE(SSPC.START_DATE,'%d/%m/%Y') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_INICIO
, CASE WHEN TRIM(SSPC.INSTALL_DATE)<>'' THEN STR_TO_DATE(LEFT(SSPC.INSTALL_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_INSTALACION
, CASE WHEN TRIM(SSPC.END_DATE)<>'' THEN STR_TO_DATE(LEFT(SSPC.END_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_FIN
,NOW()
,NOW()
FROM STAGE.STG_PRODUCTOS_CRM SSPC
INNER JOIN ODS.ODS_DM_PRODUCTOS OODP ON CASE WHEN TRIM(SSPC.PRODUCT_NAME)<>'' THEN UPPER(TRIM(SSPC.PRODUCT_NAME)) ELSE 'DESCONOCIDO' END=OODP.DE_PRODUCTO
INNER JOIN ODS.ODS_DM_CANALES OODC ON CASE WHEN TRIM(SSPC.`CHANNEL`)<>'' THEN UPPER(TRIM(SSPC.`CHANNEL`)) ELSE 'DESCONOCIDO' END=OODC.DE_CANAL
INNER JOIN ODS.ODS_HC_CLIENTES OOHC ON (OOHC.ID_CLIENTE=SSPC.CUSTOMER_ID)
LEFT OUTER JOIN ODS.TMP_DIRECCIONES_CLIENTES3 TDC ON (TDC.PRODUCT_ID=SSPC.PRODUCT_ID);

COMMIT;

ANALYZE TABLE ODS_HC_SERVICIOS;

DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES;
DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES2;
DROP TABLE IF EXISTS TMP_DIRECCIONES_CLIENTES3;

SET FOREIGN_KEY_CHECKS=1;

SELECT *
FROM STAGE.STG_PRODUCTOS_CRM
LIMIT 1000;