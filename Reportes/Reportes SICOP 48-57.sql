/*REQ-48 SUBASTAS
  DESCRIPCION: Presenta detalle de las subastas. La informaci�n que se desea desplegar es la siguiente:
�	C�dula de la instituci�n que realiz� la subasta a la baja.
�	Nombre de la Instituci�n que realiz� la subasta a la baja.
�	N�mero de procedimiento.
�	N�mero de cartel.
�	Tipo de procedimiento.
�	Modalidad: subasta a la baja.
�	Fecha de apertura (dd/mm/aaaa).
�	Fecha de invitaci�n (dd/mm/aaaa).
�	Partida.
�	L�nea.*/
use[dw_sicop]
select top 10* FROM [dbo].[hechRemates] 