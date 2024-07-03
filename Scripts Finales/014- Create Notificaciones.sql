USE GestionFarmacia
GO

CREATE TABLE Notificaciones(
	IdNotificacion int IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Correo varchar(100) NULL,
	Asunto varchar(50) NOT NULL,
	Cuerpo varchar(500) NOT NULL,
	FechaRegistro datetime NOT NULL,
	Enviado bit NOT NULL,
	FechaEnvio datetime NULL
);
GO


--pprocedimiento 
CREATE PROCEDURE sp_registro_notificacion
	@Asunto varchar(50),
	@Cuerpo varchar(500),
	@Correo varchar(100)
AS
BEGIN
	BEGIN TRANSACTION

	 INSERT INTO Notificacion
           (Correo,Asunto,Cuerpo,FechaRegistro,Enviado,FechaEnvio)
     VALUES
           (@Correo, @Asunto,@Cuerpo,GETDATE(),0,NULL)

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END
GO


create PROCEDURE sp_actualziar_notificacion
	@IDNotificacion int
AS
BEGIN
	declare @texto varchar(500);

	BEGIN TRANSACTION

	update Notificacion
	set Enviado = 1,
	FechaEnvio = GETDATE()
	where IdNotificacion = @IDNotificacion;


	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END
GO

CREATE PROCEDURE sp_obtener_notificaciones_pendientes
AS
BEGIN

		SELECT IdNotificacion,Correo,Asunto,Cuerpo
				,FechaRegistro,Enviado,FechaEnvio
		FROM Notificacion
		WHERE Enviado = 0

END
GO

