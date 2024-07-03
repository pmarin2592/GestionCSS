USE GestionFarmacia
go

CREATE TABLE SolicitudRecetas(
SolicitudID int primary key identity(1,1),
MedicoID int not null,
HospitalRecetaID int not null,
HospitalEntregaID int not null,
FechaRegistro date not null,
Estado VARCHAR(20) not null default 'Pendiente'
);
go

-- Triggers

CREATE TRIGGER trg_Bitacora_SolicitudRecetas
ON SolicitudRecetas
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @SolicitudID INT = (SELECT SolicitudID from inserted)
	DECLARE @MedicoID INT = (SELECT MedicoID from inserted)
	DECLARE @HospitalRecetaID INT = (SELECT HospitalRecetaID from inserted)
	DECLARE @HospitalEntregaID INT = (SELECT HospitalEntregaID from inserted)
	DECLARE @FechaRegistro date = (SELECT FechaRegistro from inserted)
	DECLARE @Estado VARCHAR(20) = (SELECT Estado from inserted)

	--Variables datos Viejos
	DECLARE @SolicitudIDOld INT = (SELECT SolicitudID from inserted)
	DECLARE @MedicoIDOld INT = (SELECT MedicoID from inserted)
	DECLARE @HospitalRecetaIDOld INT = (SELECT HospitalRecetaID from inserted)
	DECLARE @HospitalEntregaIDOld INT = (SELECT HospitalEntregaID from inserted)
	DECLARE @FechaRegistroOld date = (SELECT FechaRegistro from inserted)
	DECLARE @EstadoOld VARCHAR(20) = (SELECT Estado from inserted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla SolicitudRecetas Datos nuevos: ID Solicitud: '+CAST(@SolicitudID as varchar)+' ID Medico: '+ CAST(@MedicoID as varchar) 
		+ ' ID Hospital Entrega : '+CAST(@HospitalEntregaID AS varchar)+' ID Hospital Receta: '+CAST(@HospitalRecetaID AS varchar) + 'Fecha Registro: ' +cast(@FechaRegistro as varchar)+
		' Estado: '+@Estado
		+' Datos viejos ID Solicitud: '+CAST(@SolicitudIDOld as varchar)+' ID Medico: '+ CAST(@MedicoIDOld as varchar)  
		+ ' ID Hospital Entrega : '+CAST(@HospitalEntregaIDOld AS varchar)+' ID Hospital Receta: '+CAST(@HospitalRecetaIDOld AS varchar) + 'Fecha Registro: ' +cast(@FechaRegistroOld as varchar)+
		' Estado: '+@EstadoOld;
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla SolicitudRecetas Datos nuevos: ID Solicitud: '+CAST(@SolicitudID as varchar)+' ID Medico: '+ CAST(@MedicoID as varchar) 
		+ ' ID Hospital Entrega : '+CAST(@HospitalEntregaID AS varchar)+' ID Hospital Receta: '+CAST(@HospitalRecetaID AS varchar) + 'Fecha Registro: ' +cast(@FechaRegistro as varchar)+
		' Estado: '+@Estado;
    END
    ELSE
    BEGIN
       SET @Descripcion = 'DELETE en la tabla SolicitudRecetas Datos nuevos: ID Solicitud: '+CAST(@SolicitudID as varchar)+' ID Medico: '+ CAST(@MedicoID as varchar) 
		+ ' ID Hospital Entrega : '+CAST(@HospitalEntregaID AS varchar)+' ID Hospital Receta: '+CAST(@HospitalRecetaID AS varchar) + 'Fecha Registro: ' +cast(@FechaRegistro as varchar)+
		' Estado: '+@Estado
		+' Datos viejos ID Solicitud: '+CAST(@SolicitudIDOld as varchar)+' ID Medico: '+ CAST(@MedicoIDOld as varchar)  
		+ ' ID Hospital Entrega : '+CAST(@HospitalEntregaIDOld AS varchar)+' ID Hospital Receta: '+CAST(@HospitalRecetaIDOld AS varchar) + 'Fecha Registro: ' +cast(@FechaRegistroOld as varchar)+
		' Estado: '+@EstadoOld;
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos para la tabla 
create PROCEDURE sp_Insertar_SolicitudRecetas
@MedicoID int,
@HospitalRecetaID int,
@HospitalEntregaID int,
@RecetaID int,
@Medicamentos VARCHAR(MAX)
AS
BEGIN

   BEGIN TRANSACTION
	INSERT INTO SolicitudRecetas
			   (MedicoID,
			    HospitalRecetaID,
				HospitalEntregaID,
				FechaRegistro,
				Estado,
				RecetaID,
				Medicamentos)
		 VALUES
			   (@MedicoID,
				@HospitalRecetaID,
				@HospitalEntregaID,
				GETDATE(),
				'Registrado',
				@RecetaID,
				@Medicamentos
			   );

    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
    
END;
GO

CREATE PROCEDURE sp_Actualizar_SolicitudRecetas
	@SolicitudID INT,
	@MedicoID int,
	@HospitalRecetaID int,
	@HospitalEntregaID int,
	@FechaRegistro date,
	@Estado VARCHAR(20)
AS
BEGIN
      
     BEGIN TRANSACTION

		UPDATE SolicitudRecetas
		set MedicoID = @MedicoID,
			HospitalRecetaID = @HospitalRecetaID,
			HospitalEntregaID = @HospitalEntregaID,
			FechaRegistro=@FechaRegistro,
			Estado = @Estado
		WHERE SolicitudID = @SolicitudID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
GO

CREATE PROCEDURE sp_Eliminar_SolicitudRecetas
    	@SolicitudID INT
AS
BEGIN
    

	 BEGIN TRANSACTION

	 Delete from SolicitudRecetas
	 where SolicitudID = @SolicitudID;
	 
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
   
END;
GO
