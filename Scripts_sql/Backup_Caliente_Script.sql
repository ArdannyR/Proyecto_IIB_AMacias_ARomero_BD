-- Backup y respaldo

-- Backup en Caliente

backup database SIBIBLI
to disk = 'C:\Users\mtemox\Documents\mtemox\3er Semestre\Bases de Datos\Proyecto\Respaldos\SIBIBLI_Full.bak' 
with
    name = 'Respaldo Completo de SiBibli',
    description = 'Respaldo completo para recuperaci�n de desastres.',
    compression; -- Buena pr�ctica para que el archivo ocupe menos espacio
go

