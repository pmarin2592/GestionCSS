use GestionCitasExpedientes
go
-- Vista para consultar el expediente médico de un paciente
CREATE VIEW vw_ExpedientePaciente AS
SELECT 
    p.Nombre, 
    p.Apellidos, 
    e.Diagnostico, 
    e.FechaDiagnostico, 
    e.Medicamentos
FROM 
    Pacientes p
JOIN 
    Expedientes e ON p.PacienteID = e.PacienteID;

-- Vista para consultar el histórico de recetas médicas de un paciente
CREATE VIEW vw_HistoricoRecetas AS
SELECT 
    p.Nombre, 
    p.Apellidos, 
    r.Medicamentos, 
    r.FechaRegistro, 
    r.Estado
FROM 
    Pacientes p
JOIN 
    Citas c ON p.PacienteID = c.PacienteID
JOIN 
    Recetas r ON c.CitaID = r.CitaID;
