/*REQ-48 SUBASTAS
  DESCRIPCION: Presenta detalle de las subastas. La información que se desea desplegar es la siguiente:
•	Cédula de la institución que realizó la subasta a la baja.
•	Nombre de la Institución que realizó la subasta a la baja.
•	Número de procedimiento.
•	Número de cartel.
•	Tipo de procedimiento.
•	Modalidad: subasta a la baja.
•	Fecha de apertura (dd/mm/aaaa).
•	Fecha de invitación (dd/mm/aaaa).
•	Partida.
•	Línea.*/
use[dw_sicop]
select top 10* FROM [dbo].[hechRemates] 