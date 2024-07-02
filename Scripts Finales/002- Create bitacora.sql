USE GestionCitasExpedientes;
GO

-- Tabla Bitacora 
CREATE TABLE Bitacora(
	IdBitacora int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Texto varchar(MAX) NOT NULL,
	FechaEscritura datetime NOT NULL
);
go

--Procedimiento Insert
-- ============================================================
-- Author:		Nubia Brenes
-- Create date: 2024/06/29
-- Description:	Crea registro en bitacora
-- ============================================================
CREATE PROCEDURE sp_crear_bitacora
	@texto varchar(max)
AS
BEGIN
	BEGIN TRANSACTION


	INSERT INTO [dbo].[Bitacora]
           ([Texto]
           ,[FechaEscritura])
     VALUES
           (@texto
           ,GETDATE())

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END