USE [GestionCitasExpedientes]
GO

--pprocedimiento 
create PROCEDURE [dbo].[sp_obtener_recetas_proceadas]

AS
BEGIN
	select r.*
	from Recetas r
	inner join Notificaciones n on n.Asunto like 'Receta ID #'+CAST(r.RecetaID as varchar) and n.Enviado = 1
	where r.Estado = 'Procesadas' 

END
