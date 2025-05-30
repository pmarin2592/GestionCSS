USE [GestionCitasExpedientes]
GO
/****** Object:  StoredProcedure [dbo].[sp_Actualizar_Receta]    Script Date: 2/7/2024 00:11:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[sp_Actualizar_Estado_Receta]
    @RecetaID INT
AS
BEGIN
   
    
     BEGIN TRANSACTION

	UPDATE Recetas
    SET  Estado = 'Procesada'
    WHERE RecetaID = @RecetaID;
    
	IF @@ERROR <> 0
	BEGIN
		ROLLBACK;
	END

	COMMIT;
END;
