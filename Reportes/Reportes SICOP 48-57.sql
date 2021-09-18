/*REQ-48 SUBASTAS FALTA NUMERO DE CARTEL
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
CREATE PROCEDURE REP_Subastas
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, procedimientos.numeroProcedimiento as 'N�mero Procedimiento'
				,  procedimientos.modalidadProcedimiento as 'Modalidad'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, tiempoInvitacion.fecha as 'Fecha Invitaci�n'
				,carteles.numeroPartida as 'Partida'
				, carteles.numeroLinea as 'L�nea'
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
               La informaci�n que se desea desplegar es la siguiente:
				� C�dula de instituci�n que elabora el convenio marco.
				� Nombre de la instituci�n que elabora el convenio marco.
				� N�mero de procedimiento.
				� Nombre/descripci�n del convenio marco (Objeto contractual),
				� A�o.
				� Fecha de contrato (dd/mm/aaaa).
				� Vigencia de contrato.
				� N�mero de contrato.
				� C�dula de instituci�n participa.
				� Nombre de instituci�n participa.
				� N�mero de orden de pedido.
				� L�nea de orden de pedido.
				� C�digo del producto
*/

/*REQ-50 REMATES
  DESCRIPCION: 
Presenta detalle de las variables de procedimientos de remate. La informaci�n que se desea desplegar es la siguiente:
 
�	C�dula de la instituci�n que realiz� el remate. 
�	Nombre de la Instituci�n que realiz� el remate. 
�	N�mero de procedimiento.
�	N�mero de cartel.
�	Tipo de procedimiento.
�	Modalidad: remate.
�	Fecha de apertura (dd/mm/aaaa).
�	Fecha de invitaci�n (dd/mm/aaaa).
�	Partida.
�	L�nea.*/

CREATE PROCEDURE REP_Remates
	AS
		BEGIN
			SELECT
				instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, procedimientos.numeroProcedimiento as 'N�mero Procedimiento'
				,procedimientos.tipoProcedimiento as 'Tipo de Procedimiento'
				,  procedimientos.modalidadProcedimiento as 'Modalidad'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, tiempoInvitacion.fecha as 'Fecha Invitaci�n'
				,carteles.numeroPartida as 'Partida'
				, carteles.numeroLinea as 'L�nea'
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
           para dar un servicio o bien u obra, corresponda al giro comercial al cual est� registrado.
La informaci�n que se desea ver:
�	Nombre de proveedor
�	C�dula proveedor.
�	Giro de Negocio (o tipo de negocio con el que se registr� como proveedor).
�	Descripci�n del Procedimiento
�	Descripci�n del objeto contractual adjudicado
�	C�digo de Identificaci�n adjudicado
�	Subpartida
�	Tipo de moneda
�	Monto adjudicado 
�	Nombre de la Instituci�n*/

/*REQ-52 SUSPENSION DE CONTRATOS
  DESCRIPCION:Este reporte detalla los contratos que ha sido objeto de suspensi�n por parte de las instituciones.
La informaci�n que se desea ver:
 
�	N�mero de procedimiento
�	Nombre y c�dula instituci�n
�	Nombre y c�dula contratista
�	C�digo producto
�	Descripci�n del producto
�	N�mero de contrato
�	L�nea
�	Cantidad
�	Moneda
�	Precio total 
�	Fecha que inicia la suspensi�n
�	Plazo de suspensi�n
�	Fecha de reinicio del contrato*/
CREATE PROCEDURE REP_SuspensionContrato
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'C�dula Contratista'
				, productos.codigoProducto as 'C�digo Producto'
				, productos.descripcionProducto as 'Descripci�n Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'L�nea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total'
				, tiempoInicio.fecha as 'Fecha Inicio Suspensi�n Contrato'
				, contrataciones.plazoSuspension as 'Plazo Suspensi�n'
				, tiempoReanudacion.fecha 'Fecha Reanudaci�n Contrato'

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
				La informaci�n que se desea ver:
				�	N�mero de procedimiento
				�	Nombre y c�dula instituci�n
				�	Nombre y c�dula contratista
				�	C�digo producto
				�	Descripci�n del producto
				�	N�mero de contrato
				�	L�nea
				�	Cantidad contrato base
				�	Moneda
				�	Precio total contrato base
				�	Tipo de modificaci�n (Nota: corresponde si es aumento o disminuci�n)
				�	Cantidad aumentada/disminuida
				�	Moneda
				�	Precio total del aumento/disminuci�n
*/
EXEC REP_Unilateral
use [dw_sicop]
CREATE PROCEDURE REP_Unilateral
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'C�dula Contratista'
				, productos.codigoProducto as 'C�digo Producto'
				, productos.descripcionProducto as 'Descripci�n Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'L�nea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total Contrato Base'
				, contrataciones.tipoModificacion as 'Tipo de Modificaci�n'
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
				WHERE contrataciones.tipoModificacion like'Modificaci�n unilateral del contrato (Aumento)'
					or contrataciones.tipoModificacion like'Modificaci�n unilateral del contrato (Disminuci�n)'
		END;
GO
/*REQ-54 CONTRATO ADICIONAL
  DESCRIPCION:Este reporte detalla las cantidades en unidades y monto de los bienes 
              y servicios que se adquieren amparados a la figura del contrato adicional.
              La informaci�n que se desea ver:
				�	N�mero de procedimiento
				�	Nombre y c�dula instituci�n
				�	Nombre y c�dula contratista
				�	C�digo producto
				�	Descripci�n del producto
				�	N�mero de contrato
				�	L�nea
				�	Cantidad contrato base
				�	Moneda
				�	Precio total contrato base
				�	Tipo de modificaci�n 
				�	Cantidad aumentada
				�	Moneda
				�	Precio total del aumento
*/
CREATE PROCEDURE REP_ContratoAdicional
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Contratista'
				, proveedores.cedulaProveedor as 'C�dula Contratista'
				, productos.codigoProducto as 'C�digo Producto'
				, productos.descripcionProducto as 'Descripci�n Producto'
				, contratos.numeroContrato as 'Numero Contrato'
				, contrataciones.numeroLineaCartel as 'L�nea'
				,contrataciones.cantidadContratada as 'Cantidad'
				, monedas.codigoISO as 'Moneda'
				, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total Contrato Base'
				, contrataciones.tipoModificacion as 'Tipo de Modificaci�n'
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
              y su respectivo per�odo.
				La informaci�n que se desea ver:
				� N�mero de procedimiento
				� Nombre y c�dula instituci�n
				� Nombre y c�dula contratista
				� C�digo producto
				� Descripci�n del producto
				� N�mero de contrato
				� L�nea
				� Cantidad  
				� Moneda
				� Precio total  
				� Per�odo de la pr�rroga
*/
CREATE PROCEDURE REP_Prorrogas
	AS
	BEGIN
		SELECT
			procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
			,instituciones.nombreInstitucion as 'Nombre Instituci�n'
			, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
			, proveedores.nombreProveedor as 'Nombre Contratista'
			, proveedores.cedulaProveedor as 'C�dula Contratista'
			, productos.codigoProducto as 'C�digo Producto'
			, productos.descripcionProducto as 'Descripci�n Producto'
			, contratos.numeroContrato as 'Numero Contrato'
			, contrataciones.numeroLineaCartel as 'L�nea'
			,contrataciones.cantidadContratada as 'Cantidad'
			, monedas.codigoISO as 'Moneda'
			, contrataciones.precioUnitario* contrataciones.cantidadContratada as 'Precio Total'
			, tiempoInicio.fecha as 'Fecha Inicio Pr�rroga'
			, tiempoFinal.fecha as 'Fecha Final Pr�rroga'
			
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
              que se aplican a las l�neas de un contrato y su respectivo monto.
				La informaci�n que se desea ver:
				� N�mero de procedimiento
				� Nombre y c�dula instituci�n
				� Nombre y c�dula contratista
				� C�digo producto
				� Descripci�n del producto
				� N�mero de contrato
				� L�nea
				� Cantidad  
				� Precio adjudicado 
				� N�mero de reajuste
				� Precio anterior �ltimo reajuste
*/
CREATE PROCEDURE REP_Reajuste
	AS
	BEGIN
		SELECT
			procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
			,instituciones.nombreInstitucion as 'Nombre Instituci�n'
			, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
			, proveedores.nombreProveedor as 'Nombre Contratista'
			, proveedores.cedulaProveedor as 'C�dula Contratista'
			, productos.codigoProducto as 'C�digo Producto'
			, productos.descripcionProducto as 'Descripci�n Producto'
			, contratos.numeroContrato as 'Numero Contrato'
			, reajuste.numeroLineaContrato as 'L�nea'
			, reajuste.cantidadContratada as 'Cantidad'
			, adjudicaciones.montoAdjudicadoLinea as 'Precio Adjudicado'
			, reajuste.numeroReajuste as 'N�mero Reajuste'
			, reajuste.precioAnteriorUltimoReajuste as 'Precio Anterior �ltimo Reajuste'
			
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
			INNER JOIN [dbo].[dimContratos] contratos
				ON reajuste.contrato = contratos.idContrato
			INNER JOIN [dbo].[hechAdjudicaciones] adjudicaciones
				ON reajuste.procedimiento = adjudicaciones.procedimiento 
					AND reajuste.numeroLineaContrato =adjudicaciones.numeroLinea
	END;
GO

/*REQ-57 RECPECION DEL BIEN O SERVICIO
  DESCRIPCION: Este reporte detalla la informaci�n de las actas de recepci�n definitiva
               de cada entrega de un contrato u orden de pedido.
			   La informaci�n que se desea ver:
				� N�mero de procedimiento
				� Nombre y c�dula instituci�n
				� Nombre y c�dula contratista
				� Contrato/Orden de pedido
				� N�mero del acta de recepci�n definitiva
				� L�nea
				� C�digo producto
				� Descripci�n del producto
				� Moneda
				� Monto total de l�nea
				� Cantidad solicitada
				� Cantidad entregada
				� Fecha de entrega solicitada (Nota: esta fecha corresponde a la fecha de entrega inicial)
				� Fecha de entrega real
				� Cantidad de d�as adelanto /atraso
*/
CREATE PROCEDURE REP_RECEPCIONES
	AS
		BEGIN
			SELECT
			   procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
			 , instituciones.nombreInstitucion as 'Nombre Institucion'
			 , instituciones.cedulaInstitucion as 'C�dula Instituci�n'
			 , proveedores.nombreProveedor as 'Nombre Contratista'
			 , proveedores.cedulaProveedor as 'C�dula Contratista'
			 , contratos.numeroContrato as 'Numero Contrato'
			 , recepciones.numeroRecepcionDefinitiva as 'N�mero Recepcion Definitiva'
			 , recepciones.numeroLinea as 'L�nea'
			 , productos.codigoProducto as ' C�digo Producto'
			 , productos.descripcionProducto as 'Descripcion Producto'
			 , monedas.codigoISO as 'Moneda'
			 , recepciones.precio*recepciones.cantidadRealRecibida as 'Monto Total de L�nea'
			 , recepciones.cantidadRealRecibida as 'Cantidad Entregada'
			 , tiempoInicial.fecha as 'Fecha de Entrega Solicitada'
			 , tiempoEntrega.fecha as 'Fecha de Entrega Real'
			 , recepciones.diasAdelantoAtraso as ' D�as Adelanto/ Atraso'
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
				INNER JOIN [dbo].[dimMonedas] monedas
					ON recepciones.moneda = monedas.idMoneda
				INNER JOIN [dbo].[dimTiempo] tiempoInicial
					ON recepciones.fechaEntregaInicial = tiempoInicial.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoEntrega
					ON recepciones.fechaRecepcionDefinitiva = tiempoEntrega.idTiempo

END;
GO

