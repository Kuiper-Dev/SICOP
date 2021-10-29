/*REQ-38 FUNCIONARIO INHIBIDOS FINIQUITADO
  DESCRIPCION:Reporte que presenta los funcionarios inhibidos.
				La informaci�n que se desea ver:
				�	Cedula del funcionario
				�	Nombre del funcionario
				�	Instituci�n donde labora
				�	Fecha de inicio de Inhibido
				�	Fecha de fin de Inhibido
*/
CREATE PROCEDURE REP_FuncionariosInhibidos
	AS
		BEGIN
			SELECT funcionarios.cedulaFuncionario as 'C�dula del Funcionario'
				   ,funcionarios.nombreFuncionario as 'Nombre del Funcionario'
				   ,instituciones.nombreInstitucion as 'Institucio�n donde Labora'
				   ,tiempoFI.fecha as 'Fecha de Inicio de Inhibido'
				   ,tiempoFS.fecha as 'Fecha de Fin de Inhibido'
				   ,inhibiciones.estadoInhibicion as 'Estado en registro inhibido'
			FROM
				[dbo].[hechInhibicionesFuncionario] inhibiciones
				INNER JOIN [dbo].[dimFuncionarios] funcionarios
				ON inhibiciones.funcionario = funcionarios.idFuncionario
				INNER JOIN [dbo].[dimInstituciones] instituciones
				ON inhibiciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimTiempo] tiempoFI
				ON inhibiciones.fechaInicioInhibicion = tiempoFI.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoFS
				ON inhibiciones.fechaFinalInhibicion = tiempoFS.idTiempo
				ORDER BY funcionarios.nombreFuncionario
END;
GO;

/*REQ-39 INFORMACI�N RELEVANTE CARTEL FINIQUITADO
  DESCRIPCI�N: Este reporte presenta informaci�n relevante del cartel.
			   La informaci�n que se desea ver:
				*	Nombre de la instituci�n.
				*	Cedula Instituci�n.
				*	Fecha publicaci�n.
				*	N�mero de procedimiento.
				*	Tipo de procedimiento.
				*	Modalidad de procedimiento.
				*	Clasificaci�n del Objeto (bienes, servicio, obra p�blica)
				*	Monto.
				*	Estado del Cartel.
				*	C�digo de la excepci�n.
				*	Descrip. Excepci�n de la Contrataci�n.Ver Anexo Listado de  Excepciones.
*/
CREATE PROCEDURE REP_DetallesCartel
	AS
		BEGIN
			SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
					, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
					, tiempo.fecha as 'Fecha de Publicaci�n'
					, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
					, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
					, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
					, clasificacion.descripcionClasificacion as 'Clasificaci�n del Objeto'
					, carteles.montoReservado as 'Monto'
					, procedimientos.estadoProcedimiento as 'Estado Cartel'
					, procedimientos.codigoExcepcion as 'C�digo de la Excepci�n'
					, procedimientos.descripcionExcepcion 'Descripci�n de la Excepcion'
			FROM
				[dbo].[hechCarteles] carteles 
				LEFT JOIN [dbo].[dimInstituciones] instituciones
					ON carteles.institucion = instituciones.idInstitucion
				LEFT JOIN [dbo].[dimTiempo] tiempo
					ON carteles.fechaPublicacion = tiempo.idTiempo 
				LEFT JOIN [dbo].[dimProcedimientos] procedimientos
					ON carteles.procedimiento = procedimientos.idProcedimiento
				LEFT JOIN [dbo].[dimClasificacionProductos] clasificacion
					ON carteles.clasificacionProducto = clasificacion.idClasificacionProducto
			END;
GO;

/*REQ-40 DETALLE LINEAS CARTEL FINIQUITADO
  DESCRIPCION: Presenta en detalle variables de las l�neas de carteles.
		La informaci�n que se desea ver:
			�	N�mero de Procedimiento
			�	Nombre de la Instituci�n Compradora 
			�	C�dula de la Instituci�n Compradora
			�	N�mero de Partida.
			�	N�mero de L�nea
			�	C�digo de identificaci�n
			�	Descripci�n de la L�nea
			�	Cantidad Solicitada.
			�	Precio unitario estimado.
*/
CREATE PROCEDURE REP_DetalleLineas
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Instituci�n Compradora'
				,instituciones.cedulaInstitucion as 'C�dula Instituci�n Compradora'
				,carteles.numeroPartida as 'Numero de Partida'
				,carteles.numeroLinea as 'N�mero de L�nea'
				, CONCAT(clasificacionProductos.codigoClasificacion, clasificacionProductos.codigoIdentificacion) as 'C�digo de Identificaci�n'
				,clasificacionProductos.descripcionClasificacion as 'Descripci�n de la L�nea'
				,carteles.cantidadSolicitada as 'Cantidad Solicitada'
				,carteles.precioUnitarioEstimado as 'Precio Unitario Estimado'
				
			FROM
				[dbo].[hechCarteles] carteles
				LEFT JOIN[dbo].[dimClasificacionProductos] clasificacionProductos
					ON carteles.clasificacionProducto = clasificacionProductos.idClasificacionProducto
				LEFT JOIN [dbo].[dimInstituciones] instituciones
					ON carteles.institucion = instituciones.idInstitucion
				LEFT JOIN [dbo].[dimProcedimientos] procedimientos
					ON carteles.procedimiento = procedimientos.idProcedimiento
		END;
GO;

/*REQ-41 RECURSOS DE OBJECI�N, REVOCATORIA, APELACION DE PROCEDIMIENTOS FINIQUITADO
  DESCRIPCION:Presenta en detalle los recursos de objeci�n, Revocatoria y Apelaci�n 
              de los procedimientos.
				La informaci�n que se desea ver:
				�	Numero de Procedimiento
				�	Nombre de la instituci�n
				�	Cedula de la instituci�n
				�	N�mero de Recurso.
				�	Tipo de Recurso 
				�	Fecha de presentaci�n del recurso
				�	N�mero de Acto. Nota: Si el valor del campo tipo de recurso es Objeci�n, el # de acto se refiere al # de SICOP. Si el valor del campo tipo de recurso es Revocatoria o Apelaci�n, el # de acto se refiere al # del documento del Acto de Adjudicaci�n.
				�	L�nea objetada.
				�	Nombre del Recurrente
				�	Resultado.
				�	Causa Resultado
				�	Estado del Recurso
*/
CREATE PROCEDURE REP_Recursos
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
		,instituciones.nombreInstitucion as 'Nombre Instituci�n'
		,instituciones.cedulaInstitucion as 'Cedula Instituci�n'
		,objeciones.numeroRecurso as 'N�mero de Recurso'
		,objeciones.tipoRecurso as 'Tipo de Recurso'
		,objeciones.numeroActo as 'N�mero de Acto'
		,objeciones.lineaObjetada as 'L�nea Objetada'
		,objeciones.nombreRecurrente as 'Nombre Recurrente'
		,objeciones.resultado as 'Resultado'
		,objeciones.causaResultado as ' Causa Resultado'
		,objeciones.estadoRecurso as 'Estado Recurso'
	FROM
		[dbo].[hechObjeciones] objeciones
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON objeciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
END;
GO;

/*REQ-42 PROVEEDORES ADJUDICADOS FINIQUITADO
  DESCRIPCI�N: Presenta en detalle variables de los Proveedores adjudicados. 
			   La informaci�n que se desea ver:
					�	Nombre de proveedor
					�	C�dula proveedor.
					�	Tipo de moneda
					�	Monto adjudicado 
					�	Nombre de la Instituci�n
*/

CREATE PROCEDURE REP_ProveedoresAdjudicados
	AS
		BEGIN
			SELECT
					proveedores.nombreProveedor as 'Nombre del Proveedor'
					, proveedores.cedulaProveedor as 'C�dula del Proveedor'
					,monedas.descripcionMoneda as 'Moneda'
					,adjudicaciones.montoAdjudicadoLinea as 'Monto Adjudicado'
					, instituciones.nombreInstitucion as 'Nombre de la Insituci�n'
			FROM
					[dbo].[hechAdjudicaciones] adjudicaciones
					INNER JOIN [dbo].[dimProveedores] proveedores
						ON adjudicaciones.proveedor = proveedores.idProveedor
					INNER JOIN [dbo].[dimMonedas] monedas
						ON adjudicaciones.monedaAdjudicada = monedas.idMoneda
					INNER JOIN [dbo].[dimInstituciones] instituciones
						ON adjudicaciones.institucion = instituciones.idInstitucion 
		END;
GO;

/*REQ-43 LINEAS ADJUDICADAS, DESIERTAS E INFRUCTUOSAS FINIQUITADO
  DESCRIPCION: Presenta el detalle de las l�neas adjudicadas desiertas e infructuosas 
               en un proceso.
				La informaci�n que se desea ver:
 
				�	N�mero de procedimiento.
				�	Nombre y cedula de la instituci�n
				�	Nombre y cedula del proveedor
				�	C�digo de producto.
				�	Numero de acto de adjudicaci�n
				�	C�digo de Producto.
				�	N�mero de l�nea.
				�	Cantidad Adjudicada.
				�	Precio unitario adjudicado.
				�	Tipo de moneda, descuento.
				�	IVA
				�	Otros impuestos.
				�	Acarreos.
				�	IVA por acarreos
				�	Fecha de adjudicaci�n en firme
				�	Permite recurso (si o no)
*/
CREATE PROCEDURE REP_LineasAdjudicadas
	AS
		BEGIN
			SELECT
				  procedimientos. numeroProcedimiento as 'N�mero de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'C�dula �Proveedor'
				, productos.codigoProducto as 'C�digo Producto'
				, adjudicaciones.numeroActo as 'N�mero de Acto'
				, adjudicaciones.numeroLinea as 'N�mero de L�nea'
				, adjudicaciones.cantidadAdjudicada as 'Cantidad Adjudicada'
				, adjudicaciones.precioUnitarioAdjudicado as 'Precio Unitario Adjudicado'
				, adjudicaciones.monedaAdjudicada as 'Moneda'
				, adjudicaciones.descuento as 'Descuento'
				, adjudicaciones.IVA as 'IVA'
				, adjudicaciones.acarreo as 'Acarreos'
				, adjudicaciones.otroImpuesto as 'Otros impuestos'
				, tiempoAdjudicacion.fecha as 'Fecha Adjudicaci�n en Firme'
				, adjudicaciones.permiteRecursos as 'Permite Recursos'
			FROM
				[dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON adjudicaciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON adjudicaciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON adjudicaciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON adjudicaciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimTiempo] tiempoAdjudicacion
					ON adjudicaciones.fechaAdjudicacionFirme = tiempoAdjudicacion.idTiempo

		END;
GO;
/*REQ-44 CONTRATOS FINIQUITADO
  DESCRIPCIONES:Presenta en detalle variables de los contratos realizados.
	La informaci�n que se desea ver:
	�	N�mero de procedimiento
	�	Nombre y c�dula de la instituci�n
	�	Nombre y c�dula del contratista 
	�	C�digo de producto
	�	Descripci�n del producto
	�	N�mero de Contrato.
	�	Secuencia.
	�	Modificaci�n.
		o	Suspensi�n de contrato
		o	suspensi�n de plazo de entrega
		o	modificaci�n unilateral al contrato
		o	prorrogas al contrato
		o	Otras.
	�	Fecha de Modificaci�n.
	�	Tipo de Autorizaci�n.
	�	Tipo de Disminuci�n. 
*/
CREATE PROCEDURE REP_CONTRATOS
	AS
		BEGIN
			SELECT
				  procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'C�dula Proveedor'
				, productos.codigoProducto as 'C�digo Producto'
				, productos.descripcionProducto as 'Descripci�n Porducto'
				, contratos.numeroContrato as 'N�mero de Contrato'
				, contrataciones.secuencia as 'Secuencia'
				, contrataciones.tipoModificacion as 'Modificaci�n'
				, tiempoModificaci�n.fecha as 'Fecha de Modificaci�n'
				, contrataciones.tipoAutorizacion as 'Tipo Autorizaci�n'
				, contrataciones.tipoDisminucion as 'Tipo Disminuci�n'
				

			FROM
				[dbo].[hechContrataciones] contrataciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contrataciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimContratos] contratos
					ON contrataciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON contratos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contrataciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON contrataciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimTiempo] tiempoModificaci�n
					ON contrataciones.fechaModificacion = tiempoModificaci�n.idTiempo
			END;
GO;

/*REQ-45 LINEAS DEL CONTRATO
  DESCRIPCION: Este reporte tiene como objetivo ampliar la informaci�n del reporte Sicop-req-fun-45:Contratos.
               La informaci�n que se desea desplegar es la siguiente:
					�	N�mero de procedimiento
					�	Nombre y cedula de la instituci�n
					�	Nombre y cedula del contratista
					�	Tipo de contrato 
					�	N�mero de Contrato
					�	Secuencia
					�	N�mero l�nea de contrato
					�	C�digo de Producto
					�	Descripci�n del producto
					�	N�mero l�nea de cartel
					�	Cantidad Contratada
					�	Tipo de moneda
					�	Precio Unitario
					�	Descuento
					�	IVA
					�	Otros impuestos
					�	Acarreos
					�	IVA de Acarreos 
*/
CREATE PROCEDURE REP_LineasContrato
	AS
		BEGIN
			SELECT
				  procedimientos.numeroProcedimiento as 'N�mero de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'C�dula Proveedor'
				, contrataciones.tipoContrato as 'Tipo Contrato'
				, contratos.numeroContrato as 'N�mero de Contrato'
				, contrataciones.secuencia as 'Secuencia'
				, contrataciones.numeroLineaContrato as 'N�mero L�nea Contrato'
				, productos.codigoProducto as 'C�digo Producto'
				, productos.descripcionProducto as 'Descripci�n Producto'
				, contrataciones.numeroLineaCartel as 'N�mero L�nea Cartel'
				, contrataciones.cantidadContratada as 'Cantidad Contratada'
				, monedas.descripcionMoneda as 'Moneda'
				, contrataciones.precioUnitario as 'Precio Unitario'
				, contrataciones.descuento as 'Descuento'
				, contrataciones.IVA as 'IVA'
				, contrataciones.otrosImpuestos as 'Otros Impuestos'
				, contrataciones.acarreos as 'Acarreos'
			FROM
				[dbo].[hechContrataciones] contrataciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON contrataciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimContratos] contratos
					ON contrataciones.contrato = contratos.idContrato
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON contratos.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON contrataciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProductos] productos
					ON contrataciones.producto = productos.idProducto
				INNER JOIN [dbo].[dimMonedas] monedas
					ON contrataciones.moneda = monedas.idMoneda
		END;
GO;
/*REQ-46 PROVEEDORES CON SANCI�N  VERIFICAR
  DESCRIPCION:Este reporte presenta informaci�n amplia de los proveedores
              que han sido sancionados. La informaci�n que se desea desplegar es
			  la siguiente:
				�	Nombre y cedula de instituci�n
				�	Nombre y cedula de proveedor 
				�	Tipo proveedor (Nacional Extranjero)
				�	Tipo de la empresa (Grande Mediana Peque�a Micro emprendedor No clasificada).
				�	Tipo de sanci�n (Inhabilitaci�n, Apercibimiento).
				�	Fecha de rige.
				�	Fecha de vencimiento. 
				�	N�mero de resoluci�n.
				�	L�nea sancionada.
				�	Estado de la sanci�n
*/
CREATE PROCEDURE REP_ProveedoresSancionados
	AS
		BEGIN
			SELECT
				  instituciones.nombreInstitucion as 'Nombre Instituci�n'
				, instituciones. cedulaInstitucion as 'C�dula Instituci�n'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'C�dula Proveedor'
				, proveedores.tipoProveedor as 'Tipo Proveedor'
				, proveedores.tamanoProveedor as 'Tipo de Empresa'
				, sanciones.tipoSancion as 'Tipo de Sanci�n'
				, tiempoInicio.fecha as 'Fecha de Inicio Sanci�n'
				, tiempoVencimiento.fecha as 'Fecha de Vencimiento'
				, sanciones.numeroResolucion as 'N�mero Resoluci�n'
				, sanciones.estadoSancion as 'Estado Resoluci�n'
			FROM
				[dbo].[hechSanciones] sanciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON sanciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON sanciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimTiempo] tiempoVencimiento
					ON sanciones.fechaFinalSancion = tiempoVencimiento.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoInicio
					ON sanciones.fechaInicioSancion = tiempoInicio.idTiempo

END;
GO;

/*REQ-47 ADJUDICACIONES FINIQUITADO
  DESCRIPCI�N:Este reporte presenta en detalle variables de las adjudicaciones. 
              La informaci�n que se desea desplegar es la siguiente:
				�	Nombre y Cedula Instituci�n.
				�	Naturaleza jur�dica.
				�	Tipo de procedimiento
				�	Numero procedimiento.
				�	Descripci�n procedimiento.
				�	L�nea.
				�	C�digo de producto
				�	Descripci�n del bien/servicio. 
				�	Cantidad.
				�	Unidad medida.
*/
CREATE PROCEDURE REP_Adjudicaciones
	AS
		BEGIN
			SELECT
				  proveedores.nombreProveedor as 'Nombre del Proveedor'
				, proveedores.cedulaProveedor as 'C�dula del Proveedor'
				, proveedores.tipoProveedor as 'Tipo del Proveedor'
				, proveedores.tamanoProveedor as 'Tama�o del Proveedor'
				, procedimientos.numeroProcedimiento as 'N�mero del Procedimiento'
				, procedimientos.descripcionExcepcion as 'Descripci�n del Procedimiento'
				, adjudicaciones.numeroLinea as 'L�nea'
				, productos.codigoProducto as 'C�digo Producto'
				, clasificacionProductos.descripcionClasificacion as 'Descripci�n del bien o servicio'
				, adjudicaciones.cantidadAdjudicada as 'Cantidad'
				, adjudicaciones.unidadMedida as 'Unidad de Medida' 
			FROM
				[dbo].[hechAdjudicaciones] adjudicaciones
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON adjudicaciones.proveedor = proveedores.idProveedor
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON adjudicaciones.procedimiento =procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimProductos] productos
					ON adjudicaciones.producto =productos.idProducto
				INNER JOIN [dbo].[dimClasificacionProductos] clasificacionProductos
					ON adjudicaciones.clasificacionProducto =clasificacionProductos.idClasificacionProducto
		END;
GO;