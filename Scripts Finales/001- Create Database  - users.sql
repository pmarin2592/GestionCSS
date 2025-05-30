CREATE DATABASE GestionCitasExpedientes;
GO

USE GestionCitasExpedientes;
GO

-- Crear usuarios
CREATE LOGIN admin_user WITH PASSWORD = 'StrongPassword1!';
CREATE USER admin_user FOR LOGIN admin_user;
ALTER ROLE db_owner ADD MEMBER admin_user;

CREATE LOGIN api_user WITH PASSWORD = 'StrongPassword2!';
CREATE USER api_user FOR LOGIN api_user;
GRANT EXECUTE,SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO api_user;
GRANT EXECUTE,SELECT, INSERT, UPDATE, DELETE ON DATABASE::GestionCitasExpedientes TO api_user;

SELECT * FROM sys.database_principals WHERE name = 'api_user';