/*REQ-48 SUBASTAS FALTA NUMERO DE CARTEL
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
CREATE PROCEDURE REP_Subastas
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, procedimientos.numeroProcedimiento as 'Número Procedimiento'
				,  procedimientos.modalidadProcedimiento as 'Modalidad'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, tiempoInvitacion.fecha as 'Fecha Invitación'
				,carteles.numeroPartida as 'Partida'
				, carteles.numeroLinea as 'Línea'
			FROM
				[dbo].[hechRemates] remates
				INNER JOIN[dbo].[dimProcedimientos] procedimientos
					ON remates.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[hechCarteles] carteles
					ON remates.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] tiempoApertura
					ON carteles.fechaApertura = tiempoApertura.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoInvitacion
					ON remates.fechaInvitacion = tiempoInvitacion.idTiempo
		END;
GO

/*REQ-49 CONVENIO MARCO
  DESCRIPCION: Presenta detalle de las variables del convenio marco. 
               La información que se desea desplegar es la siguiente:
				• Cédula de institución que elabora el convenio marco.
				• Nombre de la institución que elabora el convenio marco.
				• Número de procedimiento.
				• Nombre/descripción del convenio marco (Objeto contractual),
				• Año.
				• Fecha de contrato (dd/mm/aaaa).
				• Vigencia de contrato.
				• Número de contrato.
				• Cédula de institución participa.
				• Nombre de institución participa.
				• Número de orden de pedido.
				• Línea de orden de pedido.
				• Código del producto
*/

/*REQ-50 REMATES
  DESCRIPCION: 
Presenta detalle de las variables de procedimientos de remate. La información que se desea desplegar es la siguiente:
 
•	Cédula de la institución que realizó el remate. 
•	Nombre de la Institución que realizó el remate. 
•	Número de procedimiento.
•	Número de cartel.
•	Tipo de procedimiento.
•	Modalidad: remate.
•	Fecha de apertura (dd/mm/aaaa).
•	Fecha de invitación (dd/mm/aaaa).
•	Partida.
•	Línea.*/

CREATE PROCEDURE REP_Remates
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, procedimientos.numeroProcedimiento as 'Número Procedimiento'
				,procedimientos.tipoProcedimiento as 'Tipo de Procedimiento'
				,  procedimientos.modalidadProcedimiento as 'Modalidad'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, tiempoInvitacion.fecha as 'Fecha Invitación'
				,carteles.numeroPartida as 'Partida'
				, carteles.numeroLinea as 'Línea'
			FROM
				[dbo].[hechRemates] remates
				INNER JOIN[dbo].[dimProcedimientos] procedimientos
					ON remates.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[hechCarteles] carteles
					ON remates.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] tiempoApertura
					ON carteles.fechaApertura = tiempoApertura.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoInvitacion
					ON remates.fechaInvitacion = tiempoInvitacion.idTiempo
		END;
GO

/*REQ-51 GIRO COMERCIAL DEL CONTRATISTA
  DESCRIPCION:Presenta el detalle de los contratistas que han sido adjudicado
           para dar un servicio o bien u obra, corresponda al giro comercial al cual está registrado.
La información que se desea ver:
•	Nombre de proveedor
•	Cédula proveedor.
•	Giro de Negocio (o tipo de negocio con el que se registró como proveedor).
•	Descripción del Procedimiento
•	Descripción del objeto contractual adjudicado
•	Código de Identificación adjudicado
•	Subpartida
•	Tipo de moneda
•	Monto adjudicado 
•	Nombre de la Institución*/

/*REQ-52 SUSPENSION DE CONTRATOS
  DESCRIPCION:Este reporte detalla los contratos que ha sido objeto de suspensión por parte de las instituciones.
La información que se desea ver:
 
•	Número de procedimiento
•	Nombre y cédula institución
•	Nombre y cédula contratista
•	Código producto
•	Descripción del producto
•	Número de contrato
•	Línea
•	Cantidad
•	Moneda
•	Precio total 
•	Fecha que inicia la suspensión
•	Plazo de suspensión
•	Fecha de reinicio del contrato*/
CREATE PROCEDURE REP_SuspensionContrato
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'Cédula Contratista'
				, productos.codigoProducto as 'Código Producto'
				, productos.descripcionProducto as 'Descripción Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'Línea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total'
				, tiempoInicio.fecha as 'Fecha Inicio Suspensión Contrato'
				, contrataciones.plazoSuspension as 'Plazo Suspensión'
				, tiempoReanudacion.fecha 'Fecha Reanudación Contrato'

			FROM
				[dbo].[hechContrataciones] contrataciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contrataciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contrataciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON contrataciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimContratos] contratos
					ON contrataciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimMonedas] monedas
					ON contrataciones.moneda =monedas.idMoneda
				INNER JOIN [dbo].[dimTiempo] tiempoInicio
				ON contrataciones.fechaInicioSuspension = tiempoInicio.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoReanudacion
				ON contrataciones.fechaReanudacionContrato = tiempoReanudacion.idTiempo
		END;
GO
/*REQ-53 MODIFICACION UNILATERAL DE CONTRATO resolver bug
  DESCRIPCION:Este reporte detalla las cantidades en unidades y monto de los bienes
              y servicios que se aumentan y disminuyen amparados a la figura 
			  del contrato unilateral.
				La información que se desea ver:
				•	Número de procedimiento
				•	Nombre y cédula institución
				•	Nombre y cédula contratista
				•	Código producto
				•	Descripción del producto
				•	Número de contrato
				•	Línea
				•	Cantidad contrato base
				•	Moneda
				•	Precio total contrato base
				•	Tipo de modificación (Nota: corresponde si es aumento o disminución)
				•	Cantidad aumentada/disminuida
				•	Moneda
				•	Precio total del aumento/disminución
*/
EXEC REP_Unilateral
use [dw_sicop]
CREATE PROCEDURE REP_Unilateral
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'Cédula Contratista'
				, productos.codigoProducto as 'Código Producto'
				, productos.descripcionProducto as 'Descripción Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'Línea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total Contrato Base'
				, contrataciones.tipoModificacion as 'Tipo de Modificación'
				, contrataciones.cantidadAumentada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadAumentada as 'Monto Total Aumento'
			FROM
				[dbo].[hechContrataciones] contrataciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contrataciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contrataciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON contrataciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimContratos] contratos
					ON contrataciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimMonedas] monedas
					ON contrataciones.moneda =monedas.idMoneda
				WHERE contrataciones.tipoModificacion like'Modificación unilateral del contrato (Aumento)'
					or contrataciones.tipoModificacion like'Modificación unilateral del contrato (Disminución)'
		END;
GO
/*REQ-54 CONTRATO ADICIONAL
  DESCRIPCION:Este reporte detalla las cantidades en unidades y monto de los bienes 
              y servicios que se adquieren amparados a la figura del contrato adicional.
              La información que se desea ver:
				•	Número de procedimiento
				•	Nombre y cédula institución
				•	Nombre y cédula contratista
				•	Código producto
				•	Descripción del producto
				•	Número de contrato
				•	Línea
				•	Cantidad contrato base
				•	Moneda
				•	Precio total contrato base
				•	Tipo de modificación 
				•	Cantidad aumentada
				•	Moneda
				•	Precio total del aumento
*/
CREATE PROCEDURE REP_ContratoAdicional
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'Cédula Contratista'
				, productos.codigoProducto as 'Código Producto'
				, productos.descripcionProducto as 'Descripción Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'Línea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total Contrato Base'
				, contrataciones.tipoModificacion as 'Tipo de Modificación'
				, contrataciones.cantidadAumentada as 'Cantidad Aumentada'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadAumentada as 'Monto Total Aumento'
			FROM
				[dbo].[hechContrataciones] contrataciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contrataciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON procedimientos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contrataciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON contrataciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimContratos] contratos
					ON contrataciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimMonedas] monedas
					ON contrataciones.moneda =monedas.idMoneda
				WHERE contrataciones.tipoModificacion ='Contrato Adicional'
		END;
GO
/*REQ-55 PRORROGAS
  DESCRIPCION:El fin de este reporte es conocer cuales contratos se han prorrogado 
              y su respectivo período.
				La información que se desea ver:
				• Número de procedimiento
				• Nombre y cédula institución
				• Nombre y cédula contratista
				• Código producto
				• Descripción del producto
				• Número de contrato
				• Línea
				• Cantidad  
				• Moneda
				• Precio total  
				• Período de la prórroga
*/
CREATE PROCEDURE REP_Prorrogas
	AS
	BEGIN
		SELECT
			procedimientos.numeroProcedimiento as 'Número de Procedimiento'
			,instituciones.nombreInstitucion as 'Nombre Institución'
			, instituciones.cedulaInstitucion as 'Cédula Institución'
			, proveedores.nombreProveedor as 'Nombre Contratista'
			, proveedores.cedulaProveedor as 'Cédula Contratista'
			, productos.codigoProducto as 'Código Producto'
			, productos.descripcionProducto as 'Descripción Producto'
			, contratos.numeroContrato as 'Numero Contrato'
			, contrataciones.numeroLineaCartel as 'Línea'
			,contrataciones.cantidadContratada as 'Cantidad'
			, monedas.codigoISO as 'Moneda'
			, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total'
			, tiempoInicio.fecha as 'Fecha Inicio Prórroga'
			, tiempoFinal.fecha as 'Fecha Final Prórroga'
			
		FROM
			[dbo].[hechContrataciones] contrataciones
			INNER JOIN [dbo].[dimProcedimientos] procedimientos
				ON contrataciones.procedimiento = procedimientos.idProcedimiento
			INNER JOIN [dbo].[dimInstituciones] instituciones
				ON procedimientos.institucion = instituciones.idInstitucion
			INNER JOIN [dbo].[dimProveedores] proveedores
				ON contrataciones.proveedor = proveedores.idProveedor
			INNER JOIN [dbo].[dimProductos] productos
				ON contrataciones.producto = productos.idProducto
			INNER JOIN [dbo].[dimContratos] contratos
				ON contrataciones.contrato = contratos.idContrato
			INNER JOIN [dbo].[dimTiempo] tiempoInicio
				ON contrataciones.fechaInicioProrroga = tiempoInicio.idTiempo
			INNER JOIN [dbo].[dimTiempo] tiempoFinal
				ON contrataciones.fechaFinalProrroga = tiempoFinal.idTiempo
			INNER JOIN [dbo].[dimMonedas] monedas
				ON contrataciones.moneda =monedas.idMoneda
	END;
GO

/*REQ-56 REAJUSTE DE PRECIOS DE CONTRATOS
  DESCRIPCION:Con este reporte se desea observar los reajustes de precios 
              que se aplican a las líneas de un contrato y su respectivo monto.
				La información que se desea ver:
				• Número de procedimiento
				• Nombre y cédula institución
				• Nombre y cédula contratista
				• Código producto
				• Descripción del producto
				• Número de contrato
				• Línea
				• Cantidad  
				• Precio adjudicado 
				• Número de reajuste
				• Precio anterior último reajuste
				• Monto del Reajuste
				• Nuevo precio
				• % de incremento del último reajuste
				• Fecha de inicio
				• Fecha de fin
				• Meses a aplicar
				• Días a aplicar
				• Moneda
				• Monto total (Nota: corresponde al Monto 
				  total de periodo por número de reajuste)
*/
CREATE PROCEDURE REP_Reajuste
	AS
	BEGIN
		SELECT
			procedimientos.numeroProcedimiento AS "Número de Procedimiento"
			, instituciones.nombreInstitucion AS "Nombre Institución"
			, instituciones.cedulaInstitucion AS "Cédula Institución"
			, proveedores.nombreProveedor AS "Nombre Contratista"
			, proveedores.cedulaProveedor AS "Cédula Contratista"
			, CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
				productos.codigoProducto) AS "Código del Producto"
			, productos.descripcionProducto AS "Descripción del Producto"
			, contratos.numeroContrato AS "Número de Contrato"
			, reajuste.numeroLineaContrato AS "Línea"
			, reajuste.cantidadContratada AS "Cantidad"
			, reajuste.precioUnitario AS "Precio Adjudicado"
			, reajuste.numeroReajuste AS "Número de reajuste"
			, reajuste.precioAnteriorUltimoReajuste AS "Precio anterior del último reajuste"
			, reajuste.montoReajuste AS "Monto del reajuste"
			, reajuste.nuevoPrecio AS "Nuevo precio"
			, reajuste.porcentajeIncrementoUltimoReajuste AS "% de incremento del último reajuste"
			, tiempoInicio.fecha AS "Fecha de Inicio"
			, tiempoFin.fecha AS "Fecha Final"
			, reajuste.mesesAAplicar AS "Meses a aplicar"
			, reajuste.diasAAplicar AS "Días a aplicar"
			, monedas.codigoISO AS "Moneda"
			, reajuste.montoTotal AS "Monto Total"
		FROM
			[dbo].[hechReajustesPrecio] reajuste
			INNER JOIN [dbo].[dimProcedimientos] procedimientos
				ON reajuste.procedimiento = procedimientos.idProcedimiento
			INNER JOIN [dbo].[dimProveedores] proveedores
				ON reajuste.proveedor = proveedores.idProveedor
			INNER JOIN [dbo].[dimInstituciones]instituciones
				ON procedimientos.institucion = instituciones.idInstitucion
			INNER JOIN [dbo].[dimProductos] productos
				ON reajuste.producto = productos.idProducto
			INNER JOIN [dbo].[dimClasificacionProductos] clasificacionesProducto
				ON productos.clasificacionProducto = clasificacionesProducto.idClasificacionProducto						
			INNER JOIN [dbo].[dimContratos] contratos
				ON reajuste.contrato = contratos.idContrato
			INNER JOIN [dbo].[dimTiempo] tiempoInicio
				ON reajuste.fechaInicio = tiempoInicio.idTiempo
			INNER JOIN [dbo].[dimTiempo] tiempoFin
				ON reajuste.fechaFin = tiempoFin.idTiempo
			INNER JOIN [dbo].[dimMonedas] monedas
				ON reajuste.moneda = monedas.idMoneda
END;
GO

/*REQ-57 RECEPCION DEL BIEN O SERVICIO
  DESCRIPCION: Este reporte detalla la información de las actas de recepción definitiva
               de cada entrega de un contrato u orden de pedido.
			   La información que se desea ver:
				• Número de procedimiento
				• Nombre y cédula institución
				• Nombre y cédula contratista
				• Contrato/Orden de pedido
				• Número del acta de recepción definitiva
				• Línea
				• Código producto
				• Descripción del producto
				• Moneda
				• Monto total de línea
				• Cantidad solicitada
				• Cantidad entregada
				• Fecha de entrega solicitada (Nota: esta fecha corresponde a la fecha de entrega inicial)
				• Fecha de entrega real
				• Cantidad de días adelanto /atraso
*/
CREATE PROCEDURE REP_RECEPCIONES
	AS
		BEGIN
			SELECT
			   procedimientos.numeroProcedimiento as "Número de Procedimiento"
			 , instituciones.nombreInstitucion as "Nombre Institucion"
			 , instituciones.cedulaInstitucion as "Cédula Institución"
			 , proveedores.nombreProveedor as "Nombre Contratista"
			 , proveedores.cedulaProveedor as "Cédula Contratista"
			 , contratos.numeroContrato as "Número de Contrato/Orden pedido"
			 , recepciones.numeroRecepcionDefinitiva as "Número del acta de recepcion definitiva"
			 , recepciones.numeroLinea as "Línea"
			 , CONCAT(clasificacionesProducto.codigoClasificacion,clasificacionesProducto.codigoIdentificacion,
				productos.codigoProducto) as "Código del Producto"
			 , productos.descripcionProducto as "Descripción del Producto"
			 , monedas.codigoISO as "Moneda"
			 , recepciones.precio*recepciones.cantidadRealRecibida as "Monto total de línea"
			 , carteles.cantidadSolicitada AS "Cantidad solicitada"
			 , recepciones.cantidadRealRecibida as "Cantidad entregada"
			 , tiempoInicial.fecha as "Fecha de entrega solicitada"
			 , tiempoEntrega.fecha as "Fecha de entrega real"
			 , recepciones.diasAdelantoAtraso as "Días de adelanto/atraso"
			FROM
				[dbo].[hechRecepciones] recepciones
				INNER JOIN[dbo].[dimContratos] contratos
					ON recepciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON contratos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contratos.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contratos.procedimiento = procedimientos.idProcedimiento				
				INNER JOIN [dbo].[dimProductos] productos
					ON recepciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimClasificacionProductos] clasificacionesProducto
					ON productos.clasificacionProducto = clasificacionesProducto.idClasificacionProducto
				INNER JOIN [dbo].[hechContrataciones] contrataciones -- usado como intermediario para llegar a carteles
					ON recepciones.contrato = contrataciones.contrato
						AND recepciones.secuencia = contrataciones.secuencia
						AND recepciones.numeroLinea = contrataciones.numeroLineaContrato						
				INNER JOIN [dbo].[hechCarteles] carteles
					ON contrataciones.procedimiento = carteles.procedimiento
						AND contrataciones.numeroLineaCartel = carteles.numeroLinea					
				INNER JOIN [dbo].[dimMonedas] monedas
					ON recepciones.moneda = monedas.idMoneda
				INNER JOIN [dbo].[dimTiempo] tiempoInicial
					ON recepciones.fechaEntregaInicial = tiempoInicial.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoEntrega
					ON recepciones.fechaRecepcionDefinitiva = tiempoEntrega.idTiempo				
END;
GO