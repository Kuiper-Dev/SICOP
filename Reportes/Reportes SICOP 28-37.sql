/* REQ-28 TIPO DE PROCEDIMIENTOS SICOP FINIQUITADO
   DESCRIPCION: Generar un reporte que detalle los distintos tipos de figuras 
				contractuales que se realizan en SICOP. Entiéndase por tipo de procedimiento: 
				(esto debe mostrarse en la descripción del reporte: 
				“Este es un reporte ejecutivo a nivel macro, sobre lasadjudicaciones en firme”)
						*	LN: Licitación Nacional Pública.
						*	LI: Licitación Internacional.
						*	LA: Licitación Abreviada.
						*	PP: Procedimiento por principio.
						*	CD: Contratación Directa.
						*	CE: Contratación Especial.
						*	RE: Remate.
*/
CREATE PROCEDURE REP_Procedimientos
	AS
		BEGIN
			SELECT 	procedimiento.tipoProcedimiento as Procedimiento
					, count(procedimiento.idProcedimiento) as Cantidad  
			FROM [dbo].[dimProcedimientos] procedimiento 
			WHERE procedimiento.estadoProcedimiento = 'Adjudicación en firme' 
			GROUP BY procedimiento.tipoProcedimiento 
		END;
GO;

/*REQ-29 COMPRAS POR INSTITUCION, PRODUCTOS, PRECIO AÑO*/
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
  DESCRIPCIÓN:Reporte donde muestra los proveedores que han sido invitados 
              a cada licitación (proceso) realizada.
				•	Número de procedimiento.
				•	Nombre del proveedor.
				•	Cedula del proveedor.
				•	Participo, SI   NO  .
				•	Fecha que se publica el cartel.
				•	Fecha y hora de la apertura.
				•	¿Ofertó?,  SI   NO  .
				•	Código de producto.
				•	Cantidad de unidades.
*/
use[dw_sicop]
EXEC REP_InvitadosYOfertas
CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				,proveedores.nombreProveedor as 'NombreProveedor'
				,proveedores.cedulaProveedor as 'Cédula Proveedor'
				,tiempoPresentacion.fecha as 'Participó'
				,tiempoPublicacion.fecha as 'Fecha Publicacion'
				,tiempoApertura.fecha as 'Fecha Apertura'
				,productos.codigoProducto as 'Código Producto'
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
  DESCRIPCIÓN: Reporte que facilitará el conocimiento de todas las instituciones que utilizan SICOP. 
			   Poder visualizar las instituciones de Compradoras de Gobierno, 
			   Central, Adscritas, desconcentradas o autónomas. 
			   La información que se desea ver:
						*	Nombre de Institución.
						*	Fecha de ingreso a SICOP.
						*	Fecha de primera adjudicación en SICOP.
						*	Cantidad de procedimientos en total.
						*	Cantidad de procedimientos adjudicados. 
						*	Monto total adjudicado.
*/


CREATE PROCEDURE REP_InstitucionesSICOP
	AS
		BEGIN
			SELECT
				T0.nombreInstitucion as 'Nombre de la Institución'
				,T0.fechaIngreso as 'Fecha de Ingreso'
				, tiempoAdjudicacion.fecha as 'Fecha Primera Adjudicación'
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
				A saber, los tipos de Sanción son Apercibimiento e Inhabilitación. 
				La información que se desea ver:
					•	Cedula Jurídica del Proveedor
					•	Nombre del Proveedor
					•	Tipo de Sanción
					•	Descripción de la Sanción
					•	Vigencia de la Sanción
					•	Fecha final de Sanción
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
  DESCRIPCION:Reporte que muestra las órdenes de compra de cada proveedor.
			  Mostrará información de proveedores más frecuentes medidos por cantidad de órdenes de compras
			  y por monto económico adjudicado
			  Se requiere un mapa de Costa Rica en el dashboard que permita al dar clic en una zona geográfica específica
			  , abrir un cuadro de diálogo sobre información de la institución o empresa
			  , y a su vez que genere el reporte con la información descrita a continuación.
			  El mapa debe detallar
			     1- ubicación de los proveedores, 
				 2- ubicación de instituciones compradoras.
*/

CREATE PROCEDURE REP_ProveedoresYOrdenes
AS
BEGIN
END;
GO;
/*REQ-37 REPORTES PROVEEDORES-CONTRATISTAS
  DESCRIPCION: Reporte que muestra los proveedores registrados en SICOP 
			   y las instituciones públicas que compran bienes y servicios
			   La información que se desea ver:
					• Nombre del Proveedor
					• Cédula del Proveedor
					• Nombre de Institución
					• Número de Procedimiento
					• Descripción del Procedimiento
					• Monto Adjudicado
					• Estado del Concurso/Procedimiento
*/
CREATE PROCEDURE REP_Proveedores
AS
BEGIN
END;
GO;