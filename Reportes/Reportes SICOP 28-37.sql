/* REQ-28 TIPO DE PROCEDIMIENTOS SICOP FINIQUITADO
   DESCRIPCION: Generar un reporte que detalle los distintos tipos de figuras 
				contractuales que se realizan en SICOP. Enti�ndase por tipo de procedimiento: 
				(esto debe mostrarse en la descripci�n del reporte: 
				�Este es un reporte ejecutivo a nivel macro, sobre lasadjudicaciones en firme�)
						*	LN: Licitaci�n Nacional P�blica.
						*	LI: Licitaci�n Internacional.
						*	LA: Licitaci�n Abreviada.
						*	PP: Procedimiento por principio.
						*	CD: Contrataci�n Directa.
						*	CE: Contrataci�n Especial.
						*	RE: Remate.
*/
CREATE PROCEDURE REP_Procedimientos
	AS
		BEGIN
			SELECT 	procedimiento.tipoProcedimiento as Procedimiento
					, count(procedimiento.idProcedimiento) as Cantidad  
			FROM [dbo].[dimProcedimientos] procedimiento 
			WHERE procedimiento.estadoProcedimiento = 'Adjudicaci�n en firme' 
			GROUP BY procedimiento.tipoProcedimiento 
		END;
GO;

/*REQ-29 COMPRAS POR INSTITUCION, PRODUCTOS, PRECIO A�O*/
CREATE PROCEDURE REP_ComprasInstitucion
	AS
		BEGIN
		END;
GO;

/*REQ-30 MERCANCIAS, SERVICIOS Y BIENES MAS COMPRADOS*/
CREATE PROCEDURE REP_Mercancias
	AS
		BEGIN
		END;
GO;

/*REQ-31 Invitados y Ofertas por proceso FINIQUITADO
  DESCRIPCI�N:Reporte donde muestra los proveedores que han sido invitados 
              a cada licitaci�n (proceso) realizada.
				�	N�mero de procedimiento.
				�	Nombre del proveedor.
				�	Cedula del proveedor.
				�	Participo, SI   NO  .
				�	Fecha que se publica el cartel.
				�	Fecha y hora de la apertura.
				�	�Ofert�?,  SI   NO  .
				�	C�digo de producto.
				�	Cantidad de unidades.
*/
use[dw_sicop]
EXEC REP_InvitadosYOfertas
CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				,proveedores.nombreProveedor as 'NombreProveedor'
				,proveedores.cedulaProveedor as 'C�dula Proveedor'
				,tiempoPresentacion.fecha as 'Particip�'
				,tiempoPublicacion.fecha as 'Fecha Publicacion'
				,tiempoApertura.fecha as 'Fecha Apertura'
				,productos.codigoProducto as 'C�digo Producto'
				,ofertas.cantidadOfertada as 'Cantidad de Unidades'
			FROM
				[dbo].[hechInvitaciones] invitaciones
				INNER JOIN[dbo].[dimProcedimientos] procedimientos
					ON invitaciones.procedimiento=procedimientos.idProcedimiento
				INNER JOIN[dbo].[dimProveedores] proveedores
					ON invitaciones.proveedor=proveedores.idProveedor
				LEFT JOIN [dbo].[hechOfertas] ofertas
					ON invitaciones.proveedor= ofertas.proveedor
				LEFT JOIN [dbo].[dimTiempo] tiempoPresentacion
					ON ofertas.fechaPresentacion=tiempoPresentacion.idTiempo
				INNER JOIN [dbo].[hechCarteles] carteles
					ON invitaciones.procedimiento=carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] tiempoPublicacion
					ON carteles.fechaPublicacion=tiempoPublicacion.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoApertura
					ON carteles.fechaApertura=tiempoApertura.idTiempo
				INNER JOIN [dbo].[dimProductos] productos
					ON ofertas.producto = productos.idProducto
		END;
GO;



/*REQ-34 INSTITUCIONES QUE UTILIZAN SICOP FINIQUITADO
  DESCRIPCI�N: Reporte que facilitar� el conocimiento de todas las instituciones que utilizan SICOP. 
			   Poder visualizar las instituciones de Compradoras de Gobierno, 
			   Central, Adscritas, desconcentradas o aut�nomas. 
			   La informaci�n que se desea ver:
						*	Nombre de Instituci�n.
						*	Fecha de ingreso a SICOP.
						*	Fecha de primera adjudicaci�n en SICOP.
						*	Cantidad de procedimientos en total.
						*	Cantidad de procedimientos adjudicados. 
						*	Monto total adjudicado.
*/


CREATE PROCEDURE REP_InstitucionesSICOP
	AS
		BEGIN
			SELECT
				T0.nombreInstitucion as 'Nombre de la Instituci�n'
				,T0.fechaIngreso as 'Fecha de Ingreso'
				, tiempoAdjudicacion.fecha as 'Fecha Primera Adjudicaci�n'
				,T0.[Total Procedimientos] as 'Total de Procedimientos'
				,T0.[Procedimientos adjudicados] as 'Procedimientos Adjudicados'
				, SUM(adjudicaciones.montoAdjudicadoLineaUSD) as 'Monto Total Adjudicado'

			FROM
				(SELECT
				instituciones.idInstitucion
				,instituciones.nombreInstitucion
				,instituciones.fechaIngreso
				,COUNT(procedimientos.idProcedimiento) as 'Total Procedimientos'
				,SUM(CASE 
							WHEN procedimientos.estadoProcedimiento like'Adjudicado'
								THEN 1 
								ELSE 0 
									END) as 'Procedimientos adjudicados'
			FROM
				[dbo].[dimProcedimientos]procedimientos
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion= instituciones.idInstitucion
	
			GROUP BY instituciones.idInstitucion,instituciones.nombreInstitucion, instituciones.fechaIngreso) AS T0
			INNER JOIN [dbo].[hechAdjudicaciones] adjudicaciones
				ON T0.idInstitucion=adjudicaciones.institucion
			INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
				ON adjudicaciones.fechaAdjudicacionFirme = tiempoAdjudicacion.idTiempo
			GROUP BY T0.nombreInstitucion, T0.fechaIngreso, tiempoAdjudicacion.fecha, T0.[Total Procedimientos], T0.[Procedimientos adjudicados]
		END;
GO;

/*REQ-35 SANCIONES A PROVEEDORES
  DESCRIPCION:  Reporte que muestra las sanciones aplicadas a proveedores. 
				A saber, los tipos de Sanci�n son Apercibimiento e Inhabilitaci�n. 
				La informaci�n que se desea ver:
					�	Cedula Jur�dica del Proveedor
					�	Nombre del Proveedor
					�	Tipo de Sanci�n
					�	Descripci�n de la Sanci�n
					�	Vigencia de la Sanci�n
					�	Fecha final de Sanci�n
*/
CREATE PROCEDURE REP_SancionesProveedores
	AS
		BEGIN
			SELECT
					proveedores.cedulaProveedor
					,proveedores.nombreProveedor
					,sanciones.tipoSancion
					, sanciones.descripcionSancion
					, tiempoIS.fecha
					, tiempoFS.fecha
			FROM	[dbo].[hechSanciones] sanciones
					INNER JOIN [dbo].[dimProveedores] proveedores
						ON sanciones.proveedor= proveedores.idProveedor
					INNER JOIN [dbo].[dimTiempo] tiempoIS
						ON sanciones.fechaInicioSancion = tiempoIS.idTiempo
					INNER JOIN [dbo].[dimTiempo] tiempoFS
						ON sanciones.fechaFinalSancion = tiempoFS.idTiempo
			END;
GO;
/*REQ-36 REPORTES PROVEEDORES-CONTRATISTAS
  DESCRIPCION:Reporte que muestra las �rdenes de compra de cada proveedor.
			  Mostrar� informaci�n de proveedores m�s frecuentes medidos por cantidad de �rdenes de compras
			  y por monto econ�mico adjudicado
			  Se requiere un mapa de Costa Rica en el dashboard que permita al dar clic en una zona geogr�fica espec�fica
			  , abrir un cuadro de di�logo sobre informaci�n de la instituci�n o empresa
			  , y a su vez que genere el reporte con la informaci�n descrita a continuaci�n.
			  El mapa debe detallar
			     1- ubicaci�n de los proveedores, 
				 2- ubicaci�n de instituciones compradoras.
*/

CREATE PROCEDURE REP_ProveedoresYOrdenes
AS
BEGIN
END;
GO;
/*REQ-37 REPORTES PROVEEDORES-CONTRATISTAS
  DESCRIPCION: Reporte que muestra los proveedores registrados en SICOP 
			   y las instituciones p�blicas que compran bienes y servicios
			   La informaci�n que se desea ver:
					� Nombre del Proveedor
					� C�dula del Proveedor
					� Nombre de Instituci�n
					� N�mero de Procedimiento
					� Descripci�n del Procedimiento
					� Monto Adjudicado
					� Estado del Concurso/Procedimiento
*/
CREATE PROCEDURE REP_Proveedores
AS
BEGIN
END;
GO;