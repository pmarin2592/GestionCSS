CREATE DATABASE GestionFarmacia;
GO

USE GestionFarmacia;
GO

-- Crear usuarios
CREATE LOGIN admin_farmacia WITH PASSWORD = 'StrongPassword1!';
CREATE USER admin_farmacia FOR LOGIN admin_farmacia;
ALTER ROLE db_owner ADD MEMBER admin_farmacia;

CREATE LOGIN api_farmacia WITH PASSWORD = 'StrongPassword2!';
CREATE USER api_farmacia FOR LOGIN api_farmacia;
GRANT Execute, SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO api_farmacia;