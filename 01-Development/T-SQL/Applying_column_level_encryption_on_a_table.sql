/*
Written By: Alok Ranjan (Empower TopTech Solutions)
Important Warning
    - Do NOT run or apply these results directly in a Production Environment.
    - Always validate in a lower environment first (Dev / QA / UAT).
    - Any loss or permanent change done by script is not responsiblity of Author, only the executor will be responsible.
    - This script creates encryption keys/certificates and modifies schema. Executor is solely responsible.
*/

/*
Name: Applying_column_level_encryption_on_a_table.sql
Description :
    - Demonstrates step-by-step process to apply column-level encryption in SQL Server.
    - Creates Service Master Key, Database Master Key, Self-signed Certificate, and Symmetric Key.
    - Adds encrypted columns and migrates existing data into encrypted format.
    - Provides queries to read/decrypt data and filter encrypted columns.
    - Implements INSTEAD OF trigger to handle insert/update seamlessly with encryption.
Execution Instruction:
    - Before execution: Run in a test environment; update database and key/certificate details as needed.
    - After execution: Verify encryption/decryption logic; validate that insert/update operations work transparently.
*/


---------------------------------------------------------------------
-- APPLYING COLUMN LEVEL ENCRYPTION ON A TABLE
---------------------------------------------------------------------
-- SHOW HOW TO APPLY ENCRYPTION ON EXISTING DATA OF DATE COLUMN, NUMERIC COLUMN, and TEXT COLUMN OF A TABLE 
-- SHOW HOW TO INSERT DATA/ UPDATE DATA TO TABLE WITHOUT CHANGING EXISTING INSERT/ UPDATE COMMANDS OF CODE
-- SHOW HOW TO READ DATA OF COLUMNS HAVING ENCRYPTION 
-- SHOW HOW TO APPLY WHERE/FILTER CONDITION ON ENCRYPTED COLUMN
-- DISCUSS HOW TO HANDLE FUTURE SCHEMA CHANGE 
	-- BY ADDING NEW COLUMN WITHOUT ENCRYPTION
	-- alokBY ADDING NEW COLUMN WITH ENCRYPTION

/*
Step 1 - 
	CREATE DATABASE FOR TESTING 
	CREATE TABLE 
	INSERT DATA TO NEWLY CREATED TABLE
*/
create database z_ars_encrypt_column_data_testing;
go
use z_ars_encrypt_column_data_testing
go
create table customer (
	customer_id int identity(1,1) primary key,
	customer_name varchar(500),
	date_of_birth datetime,
	email_id varchar(500),
	monthly_salary int
)
go
insert into customer(customer_name,date_of_birth,email_id,monthly_salary) 
values
('AlokRanj','1987-01-06','test.check1@gmail.com',111111)
,('Brajesh','1986-01-06','best.check2@gmail.com',222222)
,('Chandra','1996-01-06','rest.check3@gmail.com',333333)
,('Deepaak','2002-01-06','gust.check4@gmail.com',456123)
,('Keertii','2010-01-06','rust.check5@gmail.com',123456)

go
select * from customer

/*
Step 2 - SQL Server Service Master Key
CHECK Service Master Key and IT SHOULD EXISTS 
IF NOT EXIST WE NEED TO MANUALLY CREATE IT
*/
USE master;
GO
SELECT *
FROM sys.symmetric_keys
WHERE name = '##MS_ServiceMasterKey##';
GO
/*
Step 3 - SQL Server Database Master Key
YOU CAN CHANGE THE PASSWORD HERE
*/
-- Create database Key
USE z_ars_encrypt_column_data_testing;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '03T84xDTbKPPSS87$%%DDD'; -- you can change the password here
GO

/*
Step 4 - Create a Self Signed SQL Server Certificate:
*/
-- Create self signed certificate
USE z_ars_encrypt_column_data_testing;
GO
CREATE CERTIFICATE certProtectData
WITH SUBJECT = 'Protect Data';
GO

/*
Step 5 - SQL Server Symmetric Key
*/
-- Create symmetric Key
USE z_ars_encrypt_column_data_testing;
GO
CREATE SYMMETRIC KEY symmKeyProtectData 
 WITH ALGORITHM = AES_128 
 ENCRYPTION BY CERTIFICATE certProtectData;
GO

/*
Step 6 - Schema changes
*/
USE z_ars_encrypt_column_data_testing;
GO
ALTER TABLE customer ADD date_of_birth_encrypt varbinary(MAX) NULL
ALTER TABLE customer ADD email_id_encrypt varbinary(MAX) NULL
ALTER TABLE customer ADD monthly_salary_encrypt varbinary(MAX) NULL
GO
SELECT * FROM customer

/*
Step 7 - Encrypting the newly created column
*/
-- Populating encrypted data into new column
USE z_ars_encrypt_column_data_testing;
GO
-- Opens the symmetric key for use
OPEN SYMMETRIC KEY symmKeyProtectData
DECRYPTION BY CERTIFICATE certProtectData;
GO
UPDATE customer
	SET 
		date_of_birth_encrypt = EncryptByKey (Key_GUID('symmKeyProtectData'),cast(date_of_birth as varchar(500)))
		,email_id_encrypt = EncryptByKey (Key_GUID('symmKeyProtectData'),email_id)
		,monthly_salary_encrypt = EncryptByKey (Key_GUID('symmKeyProtectData'),cast(monthly_salary as varchar(500)))
FROM dbo.customer;
GO
-- Closes the symmetric key
CLOSE SYMMETRIC KEY symmKeyProtectData;
GO

SELECT * FROM customer


/*
Step 8 - Reading the SQL Server Encrypted Data
*/

USE z_ars_encrypt_column_data_testing;
GO
OPEN SYMMETRIC KEY symmKeyProtectData
DECRYPTION BY CERTIFICATE certProtectData;
GO
-- Now list the original ID, the encrypted ID 
SELECT Customer_id
	
	, date_of_birth
	, date_of_birth_encrypt
	, CAST(CONVERT(varchar, DecryptByKey(date_of_birth_encrypt)) as DATETIME) AS 'Decrypted Date Of Birth'
	, email_id
	, email_id_encrypt
	, CONVERT(varchar, DecryptByKey(email_id_encrypt)) AS 'Decrypted Email ID'
	, monthly_salary
	, monthly_salary_encrypt
	, CONVERT(varchar, DecryptByKey(monthly_salary_encrypt)) AS 'Decrypted Salary'
FROM dbo.customer;
 
 -- Close the symmetric key
CLOSE SYMMETRIC KEY symmKeyProtectData;
GO

/*
Step 9 - Adding Data to table in encrypted format
	CREATE INSTEAD OF TRIGGER to handle the insertion of cneypted data
*/
-- =============================================
-- Author:		AlokRanjan
-- Create date: 11/May/2023
-- Description:	<Description,,>
-- =============================================
CREATE OR ALTER TRIGGER instd_trg_customer
   ON  customer
   INSTEAD OF INSERT,DELETE,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	OPEN SYMMETRIC KEY symmKeyProtectData
	DECRYPTION BY CERTIFICATE certProtectData;
	
	-----------------------------------------------------------
	-- INSERT RECORD
	-----------------------------------------------------------
	IF (SELECT COUNT(1) FROM inserted where customer_id = 0) > 0
	BEGIN 
		INSERT INTO customer(customer_name, date_of_birth_encrypt, email_id_encrypt, monthly_salary_encrypt)
		SELECT ins.customer_name
			,EncryptByKey (Key_GUID('symmKeyProtectData'),cast(ins.date_of_birth as varchar(500)))
			,EncryptByKey (Key_GUID('symmKeyProtectData'),ins.email_id)
			,EncryptByKey (Key_GUID('symmKeyProtectData'),cast(ins.monthly_salary as varchar(500)))
		FROM inserted as ins
		WHERE customer_id = 0 -- customer_id will be zero for all the insert data becasue this is identity column
	END
	-----------------------------------------------------------
	-- Update Record 
	-----------------------------------------------------------
	IF (SELECT COUNT(1) FROM inserted where customer_id > 0) > 0
	BEGIN 
		UPDATE cus
		SET 
			cus.customer_name = ins.customer_name
			, cus.date_of_birth_encrypt = 
				CASE WHEN ins.date_of_birth  IS NOT NULL 
					THEN EncryptByKey (Key_GUID('symmKeyProtectData'),cast(ins.date_of_birth as varchar(500)))
					ELSE cus.date_of_birth_encrypt END
			, cus.email_id_encrypt = 
				CASE WHEN ins.email_id  IS NOT NULL 
					THEN EncryptByKey (Key_GUID('symmKeyProtectData'),ins.email_id)
					ELSE cus.email_id_encrypt END
			, cus.monthly_salary_encrypt = 
				CASE WHEN ins.monthly_salary  IS NOT NULL 
					THEN EncryptByKey (Key_GUID('symmKeyProtectData'),cast(ins.monthly_salary as varchar(500)))
					ELSE cus.monthly_salary_encrypt END
		FROM customer as cus
		INNER JOIN inserted as ins on cus.customer_id = ins.customer_id
		WHERE ins.customer_id > 0
	END

END
GO
-- DATA INSERTION.. data will not go to he above columns
USE z_ars_encrypt_column_data_testing;
GO
INSERT INTO customer(customer_name, date_of_birth, email_id, monthly_salary)
VALUES ('AlokRan_3','1999-01-06','test.check.13@gmail.com',99999)

INSERT INTO customer(customer_name, date_of_birth, email_id, monthly_salary)
SELECT *
FROM 
(
SELECT 'AlokRan_6_1' as customer_name ,'1999-01-06' as date_of_birth,'test.check.13@gmail.com' as email_id,99999 as salary
UNION ALL
SELECT 'AlokRan_6_2','1999-01-06','test.check.13@gmail.com',99999
) AS AA

go

-----------------------------
-- RECORD UPDATE
-----------------------------
UPDATE customer 
set email_id = 'test.check.81@gmail.com'
where customer_name='AlokRan_6_1'

------------------------------------------------
------ READ DATA
------------------------------------------------
OPEN SYMMETRIC KEY symmKeyProtectData
DECRYPTION BY CERTIFICATE certProtectData;
SELECT Customer_id
	,customer_name
	, CAST(CONVERT(varchar, DecryptByKey(date_of_birth_encrypt)) as DATETIME) AS date_of_birth
	, CONVERT(varchar, DecryptByKey(email_id_encrypt)) AS email_id
	, CONVERT(varchar, DecryptByKey(monthly_salary_encrypt)) AS monthly_salary
FROM dbo.customer
WHERE CAST(CONVERT(varchar, DecryptByKey(date_of_birth_encrypt)) as DATETIME) ='1999-01-06 00:00:00.000'
;
CLOSE SYMMETRIC KEY symmKeyProtectData;
