# FACTURAS
# CREACIÓN DE TABLAS
USE ODS;

#ALTER TABLE ODS_HC_FACTURAS DROP FOREIGN KEY fk_cl
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS ODS_HC_FACTURAS;

CREATE TABLE ODS_HC_FACTURAS
(ID_FACTURA INT NOT NULL PRIMARY KEY
, ID_CLIENTE INT
, FC_INICIO DATETIME
, FC_FIN DATETIME
, FC_ESTADO DATETIME
, FC_PAGO DATETIME
, ID_CICLO_FACTURACION INT
, ID_METODO_PAGO INT
, CANTIDAD INT
, FC_INSERT DATETIME
, FC_MODIFICATION DATETIME);

DROP TABLE IF EXISTS ODS_DM_METODOS_PAGO;

CREATE TABLE ODS_DM_METODOS_PAGO 
(ID_METODO_PAGO INT AUTO_INCREMENT NOT NULL PRIMARY KEY
, DE_METODO_PAGO VARCHAR(512)
, FC_INSERT DATETIME
, FC_MODIFICACION DATETIME);

DROP TABLE IF EXISTS ODS_DM_CICLOS_FACTURACION;

CREATE TABLE ODS_DM_CICLOS_FACTURACION
(ID_CICLO_FACTURACION INT AUTO_INCREMENT PRIMARY KEY
, DE_CICLO_FACTURACION VARCHAR(512)
, FC_INSERT DATETIME
, FC_MODIFICACION DATETIME);

# CREACIÓN DE FK

ALTER TABLE ODS_HC_FACTURAS ADD INDEX fk_fac_cli_idx (ID_CLIENTE ASC);
#ALTER TABLE ODS_HC_CLIENTES MODIFY COLUMN ID_SEXO INT(10) UNSIGNED;
ALTER TABLE ODS_HC_FACTURAS ADD CONSTRAINT fk_fac_cli FOREIGN KEY(ID_CLIENTE)
   REFERENCES ODS_HC_CLIENTES(ID_CLIENTE);
   
ALTER TABLE ODS_HC_FACTURAS ADD INDEX fk_fac_met_idx(ID_METODO_PAGO ASC);
ALTER TABLE ODS_HC_FACTURAS ADD CONSTRAINT fk_fac_met FOREIGN KEY (ID_METODO_PAGO)
REFERENCES ODS_DM_METODOS_PAGO(ID_METODO_PAGO);   
   
ALTER TABLE ODS_HC_FACTURAS ADD INDEX fk_fac_ciclos_idx(ID_CICLO_FACTURACION ASC);
ALTER TABLE ODS_HC_FACTURAS ADD CONSTRAINT fk_fac_ciclos FOREIGN KEY (ID_CICLO_FACTURACION)
REFERENCES ODS_DM_CICLOS_FACTURACION(ID_CICLO_FACTURACION);

# POBLAMOS EL MODELO

INSERT INTO ODS_DM_METODOS_PAGO (DE_METODO_PAGO, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(BILL_METHOD)) METODO_PAGO
, NOW(),NOW()
FROM STAGE.STG_FACTURAS_FCT
WHERE TRIM(BILL_METHOD)<>'';
INSERT INTO ODS_DM_METODOS_PAGO VALUES (-1,'DESCONOCIDO', NOW(),NOW());
INSERT INTO ODS_DM_METODOS_PAGO VALUES (-2,'NO APLICA', NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_METODOS_PAGO;

SELECT *
FROM ODS.ODS_DM_METODOS_PAGO;

INSERT INTO ODS_DM_CICLOS_FACTURACION (DE_CICLO_FACTURACION, FC_INSERT, FC_MODIFICACION)
SELECT DISTINCT UPPER(TRIM(BILL_CYCLE)) CICLO_FACTURACION
, NOW(),NOW()
FROM STAGE.STG_FACTURAS_FCT
WHERE TRIM(BILL_CYCLE)<>'';
INSERT INTO ODS_DM_CICLOS_FACTURACION VALUES (-1,'DESCONOCIDO', NOW(),NOW());
INSERT INTO ODS_DM_CICLOS_FACTURACION VALUES (-2,'NO APLICA', NOW(),NOW());
COMMIT;
ANALYZE TABLE ODS_DM_CICLOS_FACTURACION;

SELECT *
FROM ODS.ODS_DM_CICLOS_FACTURACION;

#CUIDADO CON EL AMOUNT QUE ESTÁ EN VARCHAR

SET FOREIGN_KEY_CHECKS=0;

TRUNCATE ODS.ODS_HC_FACTURAS;

INSERT INTO ODS_HC_FACTURAS
SELECT DISTINCT BILL_REF_NO ID_FACTURA
, CUSTOMER_ID ID_CLIENTE
, CASE WHEN TRIM(START_DATE)<>'' THEN STR_TO_DATE(LEFT(START_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_INICIO
, CASE WHEN TRIM(END_DATE)<>'' THEN STR_TO_DATE(LEFT(END_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_FIN
, CASE WHEN TRIM(STATEMENT_DATE)<>'' THEN STR_TO_DATE(LEFT(STATEMENT_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_ESTADO
, CASE WHEN TRIM(PAYMENT_DATE)<>''THEN STR_TO_DATE(LEFT(PAYMENT_DATE,19),'%Y-%m-%d %H:%i:%s') ELSE STR_TO_DATE('31/12/9999','%d/%m/%Y') END FC_PAGO
, CICL.ID_CICLO_FACTURACION
, METD.ID_METODO_PAGO
, CASE WHEN (TRIM(AMOUNT))<>'' THEN TRIM(AMOUNT) * 1 ELSE 0 END CANTIDAD
, NOW()
, NOW()
FROM STAGE.STG_FACTURAS_FCT FACTURAS
INNER JOIN ODS.ODS_DM_METODOS_PAGO METD ON CASE WHEN TRIM(BILL_METHOD)<>'' THEN UPPER(TRIM(FACTURAS.BILL_METHOD)) ELSE 'DESCONOCIDO' END=METD.DE_METODO_PAGO
INNER JOIN ODS.ODS_DM_CICLOS_FACTURACION CICL ON CASE WHEN TRIM(BILL_CYCLE)<>'' THEN UPPER(TRIM(FACTURAS.BILL_CYCLE)) ELSE 'DESCONOCIDO' END=CICL.DE_CICLO_FACTURACION;

COMMIT;

SET FOREIGN_KEY_CHECKS=1;

DROP TABLE IF EXISTS TMP_CLIENTES_NOT_EXIST;

CREATE TABLE TMP_CLIENTES_NOT_EXIST AS
SELECT DISTINCT ODS_FACT.ID_CLIENTE
FROM ODS.ODS_HC_FACTURAS ODS_FACT
LEFT JOIN ODS.ODS_HC_CLIENTES ODS_CLI
ON ODS_FACT.ID_CLIENTE = ODS_CLI.ID_CLIENTE
WHERE ODS_CLI.ID_CLIENTE IS NULL;

ANALYZE TABLE TMP_CLIENTES_NOT_EXIST;

SELECT * FROM TMP_CLIENTES_NOT_EXIST;

SET FOREIGN_KEY_CHECKS=0;

UPDATE ODS_HC_FACTURAS ODS
INNER JOIN TMP_CLIENTES_NOT_EXIST TMP ON ODS.ID_CLIENTE = TMP.ID_CLIENTE
SET ODS.ID_CLIENTE = -1;

UPDATE ODS_HC_FACTURAS
SET ID_CLIENTE = -1
WHERE ID_CLIENTE = 99;


SET FOREIGN_KEY_CHECKS=1;

SELECT ODS_FACT.ID_CLIENTE, COUNT(ODS_FACT.ID_CLIENTE)
FROM ODS.ODS_HC_FACTURAS ODS_FACT
LEFT JOIN ODS.ODS_HC_CLIENTES ODS_CLI ON
ODS_FACT.ID_CLIENTE = ODS_CLI.ID_CLIENTE
WHERE ODS_CLI.ID_CLIENTE IS NULL
GROUP BY 1;

SELECT ID_FACTURA
FROM ODS.ODS_HC_FACTURAS
WHERE CANTIDAD < 0;

SELECT *
FROM STAGE.STG_FACTURAS_FCT
WHERE BILL_REF_NO = '572635234';


