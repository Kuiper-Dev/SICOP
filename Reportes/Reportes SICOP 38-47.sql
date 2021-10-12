/*REQ-38 FUNCIONARIO INHIBIDOS FINIQUITADO
  DESCRIPCION:Reporte que presenta los funcionarios inhibidos.
				La información que se desea ver:
				•	Cedula del funcionario
				•	Nombre del funcionario
				•	Institución donde labora
				•	Fecha de inicio de Inhibido
				•	Fecha de fin de Inhibido
*/
CREATE PROCEDURE REP_FuncionariosInhibidos
	AS
		BEGIN
			SELECT funcionarios.cedulaFuncionario as 'Cédula del Funcionario'
				   ,funcionarios.nombreFuncionario as 'Nombre del Funcionario'
				   ,instituciones.nombreInstitucion as 'Institucioón donde Labora'
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

/*REQ-39 INFORMACIÓN RELEVANTE CARTEL FINIQUITADO
  DESCRIPCIÓN: Este reporte presenta información relevante del cartel.
			   La información que se desea ver:
				*	Nombre de la institución.
				*	Cedula Institución.
				*	Fecha publicación.
				*	Número de procedimiento.
				*	Tipo de procedimiento.
				*	Modalidad de procedimiento.
				*	Clasificación del Objeto (bienes, servicio, obra pública)
				*	Monto.
				*	Estado del Cartel.
				*	Código de la excepción.
				*	Descrip. Excepción de la Contratación.Ver Anexo Listado de  Excepciones.
*/
CREATE PROCEDURE REP_DetallesCartel
	AS
		BEGIN
			SELECT	  instituciones.nombreInstitucion as 'Nombre de la institucion'
					, instituciones.cedulaInstitucion as 'Cédula Institución'
					, tiempo.fecha as 'Fecha de Publicación'
					, procedimientos.numeroProcedimiento as 'Numero Procedimiento'
					, procedimientos.tipoProcedimiento as 'Tipo Procedimiento'
					, procedimientos.modalidadProcedimiento as 'Modalidad Procedimiento'
					, clasificacion.descripcionClasificacion as 'Clasificación del Objeto'
					, carteles.montoReservado as 'Monto'
					, procedimientos.estadoProcedimiento as 'Estado Cartel'
					, procedimientos.codigoExcepcion as 'Código de la Excepción'
					, procedimientos.descripcionExcepcion 'Descripción de la Excepcion'
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
  DESCRIPCION: Presenta en detalle variables de las líneas de carteles.
		La información que se desea ver:
			•	Número de Procedimiento
			•	Nombre de la Institución Compradora 
			•	Cédula de la Institución Compradora
			•	Número de Partida.
			•	Número de Línea
			•	Código de identificación
			•	Descripción de la Línea
			•	Cantidad Solicitada.
			•	Precio unitario estimado.
*/
CREATE PROCEDURE REP_DetalleLineas
	AS
		BEGIN
			SELECT
				procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				,instituciones.nombreInstitucion as 'Nombre Institución Compradora'
				,instituciones.cedulaInstitucion as 'Cédula Institución Compradora'
				,carteles.numeroPartida as 'Numero de Partida'
				,carteles.numeroLinea as 'Número de Línea'
				, CONCAT(clasificacionProductos.codigoClasificacion, clasificacionProductos.codigoIdentificacion) as 'Código de Identificación'
				,clasificacionProductos.descripcionClasificacion as 'Descripción de la Línea'
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

/*REQ-41 RECURSOS DE OBJECIÓN, REVOCATORIA, APELACION DE PROCEDIMIENTOS FINIQUITADO
  DESCRIPCION:Presenta en detalle los recursos de objeción, Revocatoria y Apelación 
              de los procedimientos.
				La información que se desea ver:
				•	Numero de Procedimiento
				•	Nombre de la institución
				•	Cedula de la institución
				•	Número de Recurso.
				•	Tipo de Recurso 
				•	Fecha de presentación del recurso
				•	Número de Acto. Nota: Si el valor del campo tipo de recurso es Objeción, el # de acto se refiere al # de SICOP. Si el valor del campo tipo de recurso es Revocatoria o Apelación, el # de acto se refiere al # del documento del Acto de Adjudicación.
				•	Línea objetada.
				•	Nombre del Recurrente
				•	Resultado.
				•	Causa Resultado
				•	Estado del Recurso
*/
CREATE PROCEDURE REP_Recursos
AS
BEGIN
	SELECT
		procedimientos.numeroProcedimiento as 'Número de Procedimiento'
		,instituciones.nombreInstitucion as 'Nombre Institución'
		,instituciones.cedulaInstitucion as 'Cedula Institución'
		,objeciones.numeroRecurso as 'Número de Recurso'
		,objeciones.tipoRecurso as 'Tipo de Recurso'
		,objeciones.numeroActo as 'Número de Acto'
		,objeciones.lineaObjetada as 'Línea Objetada'
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
  DESCRIPCIÓN: Presenta en detalle variables de los Proveedores adjudicados. 
			   La información que se desea ver:
					•	Nombre de proveedor
					•	Cédula proveedor.
					•	Tipo de moneda
					•	Monto adjudicado 
					•	Nombre de la Institución
*/

CREATE PROCEDURE REP_ProveedoresAdjudicados
	AS
		BEGIN
			SELECT
					proveedores.nombreProveedor as 'Nombre del Proveedor'
					, proveedores.cedulaProveedor as 'Cédula del Proveedor'
					,monedas.descripcionMoneda as 'Moneda'
					,adjudicaciones.montoAdjudicadoLinea as 'Monto Adjudicado'
					, instituciones.nombreInstitucion as 'Nombre de la Insitución'
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
  DESCRIPCION: Presenta el detalle de las líneas adjudicadas desiertas e infructuosas 
               en un proceso.
				La información que se desea ver:
 
				•	Número de procedimiento.
				•	Nombre y cedula de la institución
				•	Nombre y cedula del proveedor
				•	Código de producto.
				•	Numero de acto de adjudicación
				•	Código de Producto.
				•	Número de línea.
				•	Cantidad Adjudicada.
				•	Precio unitario adjudicado.
				•	Tipo de moneda, descuento.
				•	IVA
				•	Otros impuestos.
				•	Acarreos.
				•	IVA por acarreos
				•	Fecha de adjudicación en firme
				•	Permite recurso (si o no)
*/
CREATE PROCEDURE REP_LineasAdjudicadas
	AS
		BEGIN
			SELECT
				  procedimientos. numeroProcedimiento as 'Número de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cédula ´Proveedor'
				, productos.codigoProducto as 'Código Producto'
				, adjudicaciones.numeroActo as 'Número de Acto'
				, adjudicaciones.numeroLinea as 'Número de Línea'
				, adjudicaciones.cantidadAdjudicada as 'Cantidad Adjudicada'
				, adjudicaciones.precioUnitarioAdjudicado as 'Precio Unitario Adjudicado'
				, adjudicaciones.monedaAdjudicada as 'Moneda'
				, adjudicaciones.descuento as 'Descuento'
				, adjudicaciones.IVA as 'IVA'
				, adjudicaciones.acarreo as 'Acarreos'
				, adjudicaciones.otroImpuesto as 'Otros impuestos'
				, tiempoAdjudicacion.fecha as 'Fecha Adjudicación en Firme'
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
	La información que se desea ver:
	•	Número de procedimiento
	•	Nombre y cédula de la institución
	•	Nombre y cédula del contratista 
	•	Código de producto
	•	Descripción del producto
	•	Número de Contrato.
	•	Secuencia.
	•	Modificación.
		o	Suspensión de contrato
		o	suspensión de plazo de entrega
		o	modificación unilateral al contrato
		o	prorrogas al contrato
		o	Otras.
	•	Fecha de Modificación.
	•	Tipo de Autorización.
	•	Tipo de Disminución. 
*/
CREATE PROCEDURE REP_CONTRATOS
	AS
		BEGIN
			SELECT
				  procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cédula Proveedor'
				, productos.codigoProducto as 'Código Producto'
				, productos.descripcionProducto as 'Descripción Porducto'
				, contratos.numeroContrato as 'Número de Contrato'
				, contrataciones.secuencia as 'Secuencia'
				, contrataciones.tipoModificacion as 'Modificación'
				, tiempoModificación.fecha as 'Fecha de Modificación'
				, contrataciones.tipoAutorizacion as 'Tipo Autorización'
				, contrataciones.tipoDisminucion as 'Tipo Disminución'
				

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
				INNER JOIN [dbo].[dimTiempo] tiempoModificación
					ON contrataciones.fechaModificacion = tiempoModificación.idTiempo
			END;
GO;

/*REQ-45 LINEAS DEL CONTRATO
  DESCRIPCION: Este reporte tiene como objetivo ampliar la información del reporte Sicop-req-fun-45:Contratos.
               La información que se desea desplegar es la siguiente:
					•	Número de procedimiento
					•	Nombre y cedula de la institución
					•	Nombre y cedula del contratista
					•	Tipo de contrato 
					•	Número de Contrato
					•	Secuencia
					•	Número línea de contrato
					•	Código de Producto
					•	Descripción del producto
					•	Número línea de cartel
					•	Cantidad Contratada
					•	Tipo de moneda
					•	Precio Unitario
					•	Descuento
					•	IVA
					•	Otros impuestos
					•	Acarreos
					•	IVA de Acarreos 
*/
CREATE PROCEDURE REP_LineasContrato
	AS
		BEGIN
			SELECT
				  procedimientos.numeroProcedimiento as 'Número de Procedimiento'
				, instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones.cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cédula Proveedor'
				, contrataciones.tipoContrato as 'Tipo Contrato'
				, contratos.numeroContrato as 'Número de Contrato'
				, contrataciones.secuencia as 'Secuencia'
				, contrataciones.numeroLineaContrato as 'Número Línea Contrato'
				, productos.codigoProducto as 'Código Producto'
				, productos.descripcionProducto as 'Descripción Producto'
				, contrataciones.numeroLineaCartel as 'Número Línea Cartel'
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
/*REQ-46 PROVEEDORES CON SANCIÓN  VERIFICAR
  DESCRIPCION:Este reporte presenta información amplia de los proveedores
              que han sido sancionados. La información que se desea desplegar es
			  la siguiente:
				•	Nombre y cedula de institución
				•	Nombre y cedula de proveedor 
				•	Tipo proveedor (Nacional Extranjero)
				•	Tipo de la empresa (Grande Mediana Pequeña Micro emprendedor No clasificada).
				•	Tipo de sanción (Inhabilitación, Apercibimiento).
				•	Fecha de rige.
				•	Fecha de vencimiento. 
				•	Número de resolución.
				•	Línea sancionada.
				•	Estado de la sanción
*/
CREATE PROCEDURE REP_ProveedoresSancionados
	AS
		BEGIN
			SELECT
				  instituciones.nombreInstitucion as 'Nombre Institución'
				, instituciones. cedulaInstitucion as 'Cédula Institución'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cédula Proveedor'
				, proveedores.tipoProveedor as 'Tipo Proveedor'
				, proveedores.tamanoProveedor as 'Tipo de Empresa'
				, sanciones.tipoSancion as 'Tipo de Sanción'
				, tiempoInicio.fecha as 'Fecha de Inicio Sanción'
				, tiempoVencimiento.fecha as 'Fecha de Vencimiento'
				, sanciones.numeroResolucion as 'Número Resolución'
				, sanciones.estadoSancion as 'Estado Resolución'
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
  DESCRIPCIÓN:Este reporte presenta en detalle variables de las adjudicaciones. 
              La información que se desea desplegar es la siguiente:
				•	Nombre y Cedula Institución.
				•	Naturaleza jurídica.
				•	Tipo de procedimiento
				•	Numero procedimiento.
				•	Descripción procedimiento.
				•	Línea.
				•	Código de producto
				•	Descripción del bien/servicio. 
				•	Cantidad.
				•	Unidad medida.
*/
CREATE PROCEDURE REP_Adjudicaciones
	AS
		BEGIN
			SELECT
				  proveedores.nombreProveedor as 'Nombre del Proveedor'
				, proveedores.cedulaProveedor as 'Cédula del Proveedor'
				, proveedores.tipoProveedor as 'Tipo del Proveedor'
				, proveedores.tamanoProveedor as 'Tamaño del Proveedor'
				, procedimientos.numeroProcedimiento as 'Número del Procedimiento'
				, procedimientos.descripcionExcepcion as 'Descripción del Procedimiento'
				, adjudicaciones.numeroLinea as 'Línea'
				, productos.codigoProducto as 'Código Producto'
				, clasificacionProductos.descripcionClasificacion as 'Descripción del bien o servicio'
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