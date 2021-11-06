
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

EXEC REP_InvitadosYOfertas
CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT distinct
				procedimientos.numeroProcedimiento
				,instituciones.nombreInstitucion
				,proveedores.nombreProveedor
				,proveedores.cedulaProveedor
				,(CASE WHEN invitaciones.fechaInvitacion IS NOT NULL
					THEN 
						'SÍ'
					ELSE 
						'NO'
							END) as '¿Participó?'
				,publicación.fecha as 'Publicación del Cartel'
				,apertura.fecha as 'Apertura del Cartel'
				,(CASE WHEN ofertas.fechaPresentacion IS NOT NULL
					THEN 
						'SÍ'
					ELSE 
						'NO'
							END) as '¿Ofertó?'
				,productos.codigoProducto
				,ofertas.cantidadOfertada as 'Cantidad de Unidades'

				

			FROM
				[dbo].[hechInvitaciones] invitaciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON invitaciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON invitaciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON invitaciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[hechOfertas] ofertas
					ON invitaciones.procedimiento = ofertas.procedimiento 
						AND invitaciones.proveedor = ofertas.proveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON ofertas.producto = productos.codigoProducto
				INNER JOIN[dbo].[hechCarteles] carteles
					ON invitaciones.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] apertura
					ON carteles.fechaApertura = apertura.idTiempo
				INNER JOIN [dbo].[dimTiempo] publicación
					ON carteles.fechaPublicacion = publicación.idTiempo
						
		END;
GO;

/*REQ-33 COMPARATIVO PRECIO DE UN PRODUCTO POR INSTITUCION FINIQUITADO
  DESCRIPCION: Reporte que presenta los precios finales de los códigos de producto adquiridos 
               en diferentes procesos de contratación.
				La información a presentar es la siguiente:
				•	Instituciones.
				•	Números de procedimiento.
				•	Código de producto.
				•	Descripción del bien o servicio.
				•	Precios de producto.
				•	Fecha de adjudicación.
				•	Nombre Contratista.
				•	Cedula del contratista.
*/

CREATE PROCEDURE REP_ComparativaPrecioProducto
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion
				, procedimientos.numeroProcedimiento
				, productos.codigoProducto
				, productos.descripcionProducto
				, adjudicaciones.montoAdjudicadoLinea
				, tiempoAdjudicacion.fecha
				, proveedores.nombreProveedor
				, proveedores.cedulaProveedor
				
			FROM
				[dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON adjudicaciones.institucion= instituciones.idInstitucion
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON adjudicaciones.procedimiento= procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimProductos] productos
					ON adjudicaciones.producto= productos.idProducto
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON adjudicaciones.proveedor= proveedores.idProveedor
				INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
					ON adjudicaciones.fechaAdjudicacionFirme= tiempoAdjudicacion.idTiempo
				GROUP BY instituciones.nombreInstitucion
						,procedimientos.numeroProcedimiento
						,productos.codigoProducto
						,productos.descripcionProducto
						,adjudicaciones.montoAdjudicadoLinea
						,tiempoAdjudicacion.fecha
						,proveedores.nombreProveedor
						,proveedores.cedulaProveedor
						

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
				T0.nombreInstitucion 'Nombre Institución'
				,T0.fechaIngreso as 'Fecha Ingreso SICOP'
				,MIN(tiempoAdjudicacion.fecha) as 'Fecha Primera Adjudicación SICOP '
				,T0.[Total Procedimientos] as 'Total Procedmientos'
				,T0.[Procedimientos adjudicados] as 'Total Adjudicaciones'
				,SUM(adjudicaciones.montoAdjudicadoLineaUSD) as 'Monto Total Adjudicado'

			FROM 
				(
					SELECT
						instituciones.idInstitucion,instituciones.nombreInstitucion,instituciones.fechaIngreso
						,COUNT(procedimientos.idProcedimiento) as 'Total Procedimientos'
						,SUM(CASE WHEN procedimientos.estadoProcedimiento like'Adjudicado'
								THEN 1 
								ELSE 0 
							END) as 'Procedimientos adjudicados'
					FROM
					[dbo].[dimProcedimientos] procedimientos
					INNER JOIN [dbo].[dimInstituciones] instituciones
						ON procedimientos.institucion = instituciones.idInstitucion
					GROUP BY instituciones.idInstitucion, instituciones.nombreInstitucion, instituciones.fechaIngreso
				) AS T0
				INNER JOIN [dbo].[hechAdjudicaciones] adjudicaciones
					ON T0.idInstitucion = adjudicaciones.institucion
				INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
					ON adjudicaciones.fechaAdjudicacionFirme = tiempoAdjudicacion.idTiempo
				GROUP BY T0.nombreInstitucion, T0.fechaIngreso, T0.[Total Procedimientos], T0.[Procedimientos adjudicados]
				ORDER BY T0.nombreInstitucion
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
CREATE PROCEDURE REP_ProveedoresYOrdenesInfo
AS
	BEGIN
		SELECT
			proveedores.tipoProveedor as 'Tipo de Cédula'
			,proveedores.cedulaProveedor as 'Cédula Proveedor'
			,proveedores.nombreProveedor as 'Nombre Proveedor'
			,proveedores.tamanoProveedor as 'Tipo de Empresa'
			,proveedores.provinciaProveedor as 'Provincia'
			,proveedores.cantonProveedor as 'Cantón'
			,proveedores.fechaRegistro as 'Fecha Registro'

		FROM
			[dbo].[dimProveedores] proveedores
		END;
GO;
DROP PROCEDURE	REP_ProveedoresYOrdenesContratos
CREATE PROCEDURE REP_ProveedoresYOrdenesContratos
	AS
		BEGIN
			SELECT distinct
				contratos.proveedor
				,count (contratos.idContrato) as 'Cantidad de Contratos'
			FROM 
				[dbo].[dimContratos] contratos
				GROUP BY contratos.proveedor
			END;
GO;

DROP PROCEDURE REP_ProveedoresYOrdenesSanciones
CREATE PROCEDURE REP_ProveedoresYOrdenesSanciones
	AS
		BEGIN
			SELECT distinct
				sanciones.proveedor
				,count (sanciones.numeroResolucion) as 'Cantidad de Sanciones'
			FROM 
				[dbo].[hechSanciones] sanciones
				GROUP BY sanciones.proveedor
		END;
GO;

DROP PROCEDURE REP_ProveedoresYOrdenesInvitaciones
CREATE PROCEDURE REP_ProveedoresYOrdenesInvitaciones
	AS
		BEGIN
			SELECT distinct
				invitaciones.proveedor
				,count (invitaciones.secuencia) as 'Cantidad Invitaciones'
			FROM 
				[dbo].[hechInvitaciones] invitaciones
				GROUP BY invitaciones.proveedor
			END;
GO;

DROP PROCEDURE REP_ProveedoresYOrdenesOfertas
CREATE PROCEDURE REP_ProveedoresYOrdenesOfertas
	AS
		BEGIN
			SELECT distinct
				ofertas.proveedor
				,count (ofertas.numeroOferta) as 'Cantidad de Ofertas'
			FROM 
				[dbo].[hechOfertas] ofertas
				GROUP BY ofertas.proveedor
			END;
GO;

DROP PROCEDURE REP_ProveedoresYOrdenesCompras
CREATE PROCEDURE REP_ProveedoresYOrdenesCompras
	AS
		BEGIN
			SELECT distinct
				ordenes.contrato
				,count (ordenes.numeroOrden) as 'Cantidad de Órdenes'
				,sum (ordenes.totalEstimado) as 'Monto Total Órdenes'
			FROM 
				[dbo].[hechOrdenesPedido] ordenes
				GROUP BY ordenes.contrato
			END;
GO;
/*REQ-37 REPORTES PROVEEDORES-CONTRATISTAS FINIQUITADO
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
	SELECT
		proveedores.nombreProveedor as 'Nombre Proveedor'
		,proveedores.cedulaProveedor as 'Cédula Proveedor'
		, instituciones.nombreInstitucion as 'Nombre Institución'
		, procedimientos.numeroProcedimiento as 'Nuúmero de Procedimiento'
		, procedimientos.descripcionProcedimiento as 'Descripción del Procedimiento'
		, SUM(adjudicaciones.montoAdjudicadoLinea) as 'Monto Adjudicado'
		, procedimientos.estadoProcedimiento as 'Estado del Procedimiento'
	FROM
		[dbo].[hechAdjudicaciones] adjudicaciones
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON adjudicaciones.proveedor = proveedores.idProveedor
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON adjudicaciones.procedimiento= procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON adjudicaciones.institucion= instituciones.idInstitucion
		GROUP BY proveedores.nombreProveedor
				, proveedores.cedulaProveedor
				, instituciones.nombreInstitucion
				, procedimientos.numeroProcedimiento
				, procedimientos.descripcionProcedimiento
				, procedimientos.estadoProcedimiento

END;
GO;
