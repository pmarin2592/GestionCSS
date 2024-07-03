USE GestionFarmacia
GO

CREATE TABLE MEDICAMENTOS(
MedicamentosID int primary key identity(1,1),
Nombre varchar(100) not null,
Cantidad int not null check(Cantidad >=0),
);
GO

-- Triggers

CREATE TRIGGER trg_Bitacora_MEDICAMENTOS
ON MEDICAMENTOS
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Descripcion NVARCHAR(MAX);
	--Variables datos nuevos
	DECLARE @MedicamentosID INT = (SELECT MedicamentosID from inserted)
	DECLARE @Nombre INT = (SELECT Nombre from inserted)
	DECLARE @Cantidad INT = (SELECT Cantidad from inserted)
	
	--Variables datos Viejos
	DECLARE @MedicamentosIDOld INT = (SELECT MedicamentosID from deleted)
	DECLARE @NombreOld INT = (SELECT Nombre from deleted)
	DECLARE @CantidadOld INT = (SELECT Cantidad from deleted)

    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @Descripcion = 'UPDATE en la tabla MEDICAMENTOS Datos nuevos: ID Medicamentos: '+CAST(@MedicamentosID as varchar)+' Nombre: '+ @Nombre + ' Cantidad : '+CAST(@Cantidad AS varchar)
		+' Datos viejos ID Medicamentos: '+CAST(@MedicamentosIDOld as varchar)+' Nombre: '+ @NombreOld + ' Cantidad : '+CAST(@CantidadOld AS varchar);
    END
    ELSE IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @Descripcion = 'INSERT en la tabla MEDICAMENTOS Datos nuevos: ID Medicamentos: '+CAST(@MedicamentosID as varchar)+' Nombre: '+ @Nombre + ' Cantidad : '+CAST(@Cantidad AS varchar)
    END
    ELSE
    BEGIN
       SET @Descripcion = 'DELETE en la tabla MEDICAMENTOS Datos nuevos: ID Medicamentos: '+CAST(@MedicamentosID as varchar)+' Nombre: '+ @Nombre + ' Cantidad : '+CAST(@Cantidad AS varchar)
		+' Datos viejos ID Medicamentos: '+CAST(@MedicamentosIDOld as varchar)+' Nombre: '+ @NombreOld + ' Cantidad : '+CAST(@CantidadOld AS varchar);
    END

    Exec sp_crear_bitacora @Descripcion;
END;
go

-- Procedimientos para la tabla 
CREATE PROCEDURE sp_Insertar_Medicamentos
	@Nombre varchar(100),
	@Cantidad int
AS
BEGIN


   BEGIN TRANSACTION


	INSERT INTO MEDICAMENTOS
			   (Nombre
			   ,Cantidad)
		 VALUES
			   (@Nombre,
			   @Cantidad
			   );

    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
    
END;
GO

CREATE PROCEDURE sp_Actualizar_Medicamentos
	@MedicamentosID int,
    @Nombre varchar(100),
	@Cantidad int
AS
BEGIN
      
     BEGIN TRANSACTION

		UPDATE MEDICAMENTOS
		set Nombre=@Nombre,
			Cantidad=@Cantidad
		WHERE MedicamentosID = @MedicamentosID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
GO

CREATE PROCEDURE sp_Eliminar_Medicamento
    @MedicamentoID INT
AS
BEGIN
    

	 BEGIN TRANSACTION

	 Delete from MEDICAMENTOS
	 where MedicamentosID = @MedicamentoID;
	 
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
    
   
END;
GO
