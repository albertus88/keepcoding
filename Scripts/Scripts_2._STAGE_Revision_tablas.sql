# Tabla STG_CLIENTES_CRM

USE STAGE;

SELECT COUNT(*) TOTAL_REGISTROS
, SUM(CASE WHEN LENGTH(TRIM(CUSTOMER_ID))<>0 THEN 1 ELSE 0 END) TOTAL_CUSTOMER_ID
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(CUSTOMER_ID))<>0 THEN CUSTOMER_ID ELSE 0  END) TOTAL_DISTINTOS_CUSTUMER_ID
, SUM(CASE WHEN LENGTH(TRIM(FIRST_NAME))<>0 THEN 1 ELSE 0 END) TOTAL_FIRST_NAME
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(FIRST_NAME))<>0 THEN FIRST_NAME ELSE 0  END) TOTAL_FIRST_NAME
, SUM(CASE WHEN LENGTH(TRIM(LAST_NAME))<>0 THEN 1 ELSE 0 END) TOTAL_LAST_NAME
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(LAST_NAME))<>0 THEN LAST_NAME ELSE 0  END) TOTAL_DISTINTOS_LAST_NAME
, SUM(CASE WHEN LENGTH(TRIM(IDENTIFIED_DOC))<>0 THEN 1 ELSE 0 END) TOTAL_IDENTIFIED_DOC
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(IDENTIFIED_DOC))<>0 THEN IDENTIFIED_DOC ELSE 0  END) TOTAL_DISTINTOS_IDENTIFIED_DOC
, SUM(CASE WHEN LENGTH(TRIM(GENDER))<>0 THEN 1 ELSE 0 END) TOTAL_GENDER
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(GENDER))<>0 THEN GENDER ELSE 0  END) TOTAL_DISTINTOS_GENDER
, SUM(CASE WHEN LENGTH(TRIM(CITY))<>0 THEN 1 ELSE 0 END) TOTAL_CITY
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(CITY))<>0 THEN CITY ELSE 0  END) TOTAL_DISTINTOS_CITY
, SUM(CASE WHEN LENGTH(TRIM(ADDRESS))<>0 THEN 1 ELSE 0 END) TOTAL_ADDRESS
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(ADDRESS))<>0 THEN ADDRESS ELSE 0  END) TOTAL_DISTINTOS_ADDRESS
, SUM(CASE WHEN LENGTH(TRIM(POSTAL_CODE))<>0 THEN 1 ELSE 0 END) TOTAL_POSTAL_CODE
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(POSTAL_CODE))<>0 THEN POSTAL_CODE ELSE 0  END) TOTAL_DISTINTOS_POSTAL_CODE
, SUM(CASE WHEN LENGTH(TRIM(STATE))<>0 THEN 1 ELSE 0 END) TOTAL_STATE
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(STATE))<>0 THEN STATE ELSE 0  END) TOTAL_DISTINTOS_STATE
, SUM(CASE WHEN LENGTH(TRIM(COUNTRY))<>0 THEN 1 ELSE 0 END) TOTAL_COUNTRY
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(COUNTRY))<>0 THEN COUNTRY ELSE 0  END) TOTAL_DISTINTOS_COUNTRY
, SUM(CASE WHEN LENGTH(TRIM(PHONE))<>0 THEN 1 ELSE 0 END) TOTAL_PHONE
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(PHONE))<>0 THEN PHONE ELSE 0  END) TOTAL_DISTINTOS_PHONE
, SUM(CASE WHEN LENGTH(TRIM(EMAIL))<>0 THEN 1 ELSE 0 END) TOTAL_EMAIL
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(EMAIL))<>0 THEN EMAIL ELSE 0  END) TOTAL_DISTINTOS_EMAIL
, SUM(CASE WHEN LENGTH(TRIM(BIRTHDAY))<>0 THEN 1 ELSE 0 END) TOTAL_BIRTHDAY
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(BIRTHDAY))<>0 THEN BIRTHDAY ELSE 0  END) TOTAL_DISTINTOS_BIRTHDAY
, SUM(CASE WHEN LENGTH(TRIM(PROFESION))<>0 THEN 1 ELSE 0 END) TOTAL_PROFESION
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(PROFESION))<>0 THEN PROFESION ELSE 0  END) TOTAL_DISTINTOS_PROFESION
, SUM(CASE WHEN LENGTH(TRIM(COMPANY))<>0 THEN 1 ELSE 0 END) TOTAL_COMPANY
, COUNT(DISTINCT CASE WHEN LENGTH(TRIM(COMPANY))<>0 THEN COMPANY ELSE 0  END) TOTAL_DISTINTOS_COMPANY
FROM STAGE.STG_CLIENTES_CRM;

# Tabla STG_PRODUCTOS_CRM

USE STAGE;

SELECT COUNT(*) TOTAL_REGISTROS
, SUM(CASE WHEN PRODUCT_ID IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_ID
, COUNT(DISTINCT CASE WHEN PRODUCT_ID IS NOT NULL AND PRODUCT_ID<>'' THEN PRODUCT_ID ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_ID
, SUM(CASE WHEN CUSTOMER_ID IS NOT NULL THEN 1 ELSE 0 END) TOTAL_CUSTOMER_ID
, COUNT(DISTINCT CASE WHEN CUSTOMER_ID IS NOT NULL AND CUSTOMER_ID<>'' THEN CUSTOMER_ID ELSE 0 END) TOTAL_DISTINTOS_CUSTOMER_ID
, SUM(CASE WHEN PRODUCT_NAME IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_NAME
, COUNT(DISTINCT CASE WHEN PRODUCT_NAME IS NOT NULL AND PRODUCT_NAME<>'' THEN PRODUCT_NAME ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_NAME
, SUM(CASE WHEN ACCESS_POINT IS NOT NULL THEN 1 ELSE 0 END) TOTAL_ACCESS_POINT
, COUNT(DISTINCT CASE WHEN ACCESS_POINT IS NOT NULL AND ACCESS_POINT<>'' THEN ACCESS_POINT ELSE 0 END) TOTAL_DISTINTOS_ACCESS_POINT
, SUM(CASE WHEN CHANNEL IS NOT NULL THEN 1 ELSE 0 END) TOTAL_CHANNEL
, COUNT(DISTINCT CASE WHEN CHANNEL IS NOT NULL AND CHANNEL<>'' THEN CHANNEL ELSE 0 END) TOTAL_DISTINTOS_CHANNEL
, SUM(CASE WHEN AGENT_CODE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_AGENT_CODE
, COUNT(DISTINCT CASE WHEN AGENT_CODE IS NOT NULL AND AGENT_CODE<>'' THEN AGENT_CODE ELSE 0 END) TOTAL_DISTINTOS_AGENT_CODE
, SUM(CASE WHEN START_DATE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_START_DATE
, COUNT(DISTINCT CASE WHEN START_DATE IS NOT NULL AND START_DATE<>'' THEN START_DATE ELSE 0 END) TOTAL_DISTINTOS_START_DATE
, SUM(CASE WHEN INSTALL_DATE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_INSTALL_DATE
, COUNT(DISTINCT CASE WHEN INSTALL_DATE IS NOT NULL AND INSTALL_DATE<>'' THEN INSTALL_DATE ELSE 0 END) TOTAL_DISTINTOS_INSTALL_DATE
, SUM(CASE WHEN END_DATE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_END_DATE
, COUNT(DISTINCT CASE WHEN END_DATE IS NOT NULL AND END_DATE<>'' THEN END_DATE ELSE 0 END) TOTAL_DISTINTOS_END_DATE
, SUM(CASE WHEN PRODUCT_CITY IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_CITY
, COUNT(DISTINCT CASE WHEN PRODUCT_CITY IS NOT NULL AND PRODUCT_CITY<>'' THEN PRODUCT_CITY ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_CITY
, SUM(CASE WHEN PRODUCT_ADDRESS IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_ADDRESS
, COUNT(DISTINCT CASE WHEN PRODUCT_ADDRESS IS NOT NULL AND PRODUCT_ADDRESS<>'' THEN PRODUCT_ADDRESS ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_ADDRESS
, SUM(CASE WHEN PRODUCT_POSTAL_CODE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_POSTAL_CODE
, COUNT(DISTINCT CASE WHEN PRODUCT_POSTAL_CODE IS NOT NULL AND PRODUCT_POSTAL_CODE<>'' THEN PRODUCT_POSTAL_CODE ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_POSTAL_CODE
, SUM(CASE WHEN PRODUCT_STATE IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_STATE
, COUNT(DISTINCT CASE WHEN PRODUCT_STATE IS NOT NULL AND PRODUCT_STATE<>'' THEN PRODUCT_STATE ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_STATE
, SUM(CASE WHEN PRODUCT_COUNTRY IS NOT NULL THEN 1 ELSE 0 END) TOTAL_PRODUCT_COUNTRY
, COUNT(DISTINCT CASE WHEN PRODUCT_COUNTRY IS NOT NULL AND PRODUCT_COUNTRY<>'' THEN PRODUCT_COUNTRY ELSE 0 END) TOTAL_DISTINTOS_PRODUCT_COUNTRY
FROM STAGE.STG_PRODUCTOS_CRM