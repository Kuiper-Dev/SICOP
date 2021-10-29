
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


/*REQ-30 MERCANCIAS, SERVICIOS Y BIENES MAS COMPRADOS*/

	

/*REQ-31 Invitados y Ofertas por proceso MODIFICAR
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

CREATE PROCEDURE REP_InvitadosYOfertas
	AS
		BEGIN
			SELECT TOP 50
				procedimientos.numeroProcedimiento as 'Numero de Procedimiento'
				, proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'Cedula Proveedor'
				, tiempo.fecha as 'Fecha Publicacion Cartel'
				, tiempoApertura.fecha as 'Fecha Apertura'
				, productos.codigoProducto as 'C�digo de Producto'


			FROM
				[dbo].[hechInvitaciones] invitaciones
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON invitaciones.procedimiento = procedimientos.idProcedimiento
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON invitaciones.proveedor =proveedores.idProveedor
				INNER JOIN [dbo].[hechCarteles] carteles
					ON invitaciones.procedimiento = carteles.procedimiento
				INNER JOIN [dbo].[dimTiempo] tiempo
					ON carteles.fechaPublicacion = tiempo.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoApertura
					ON carteles.fechaApertura = tiempoApertura.idTiempo
				INNER JOIN [dbo].[dimProductos] productos
					ON carteles.clasificacionProducto = productos.clasificacionProducto


		END;
GO;
/*REQ-34 INSTITUCIONES QUE UTILIZAN SICOP
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
			SELECT	instituciones.nombreInstitucion as 'Nombre Instituci�n'
					, instituciones.fechaIngreso as 'Fecha de Ingreso'
					, count(procedimientos.idProcedimiento) as 'Total de Procedimientos'
					,SUM(CASE 
							WHEN procedimientos.estadoProcedimiento like'Adjudicado'
								THEN 1 
								ELSE 0 
									END) as 'Procedimientos adjudicados'
					
					
			FROM 
				[dbo].[hechCarteles] carteles
				INNER JOIN[dbo].[dimInstituciones] instituciones
					ON carteles.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProcedimientos] procedimientos
					ON carteles.procedimiento=procedimientos.idProcedimiento
				

			GROUP BY instituciones.nombreInstitucion, instituciones.fechaIngreso 
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

SELECT 
	proveedores.nombreProveedor
	,proveedores.cedulaProveedor
	,instituciones.nombreInstitucion
	,procedimientos.numeroProcedimiento
	,procedimientos.descripcionProcedimiento
	,procedimientos.estadoProcedimiento
	,adjudicaciones.montoAdjudicadoLinea
FROM
	[dbo].[hechAdjudicaciones] adjudicaciones
	INNER JOIN[dbo].[dimProcedimientos] procedimientos
		ON adjudicaciones.procedimiento = procedimientos.idProcedimiento
	INNER JOIN [dbo].[dimInstituciones] instituciones
		ON adjudicaciones.institucion=instituciones.idInstitucion
	INNER JOIN [dbo].[dimProveedores] proveedores
		ON adjudicaciones.proveedor = proveedores.idProveedor


	

/*REQ-38 FUNCIONARIO INHIBIDOS
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
END;
GO;

/*REQ-39 INFORMACI�N RELEVANTE CARTEL
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

/*REQ-40 DETALLE LINEAS CARTEL
  DESCRIPCION: */

/*REQ-42
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
					, proveedores.cedulaProveedor as 'Cedula del Proveedor'
					,monedas.descripcionMoneda as 'Moneda'
					,adjudicaciones.montoAdjudicadoLinea as 'Monto Adjudicado'
					, instituciones.nombreInstitucion
			FROM
					[dbo].[hechAdjudicaciones] adjudicaciones
					INNER JOIN [dbo].[dimProveedores] proveedores
						ON adjudicaciones.proveedor = proveedores.idProveedor
					INNER JOIN [dbo].[dimMonedas] monedas
						ON adjudicaciones.monedaAdjudicada = monedas.idMoneda
					INNER JOIN [dbo].[dimInstituciones] instituciones
						ON adjudicaciones.institucion = instituciones.idInstitucion FOR XML PATH
		END;
GO;

/*REQ-44 Contratos
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
select top 10* from [dbo].[dimContratos]
select top 10* from [dbo].[hechContrataciones]
select top 10* from [dbo].[hechAdjudicaciones]
select top 10* from [dbo].[hechCarteles]
select top 10* from [dbo].[dimProcedimientos]
select top 10* from [dbo].[hechOfertas]
select top 10* from [dbo].[hechInvitaciones] invitaciones 
left join [dbo].[hechOfertas] ofertas 
on invitaciones.proveedor = ofertas.proveedor
SELECT 
	procedimientos.numeroProcedimiento
	, instituciones.nombreInstitucion
	, instituciones.cedulaInstitucion
	, proveedores.nombreProveedor
	, proveedores.cedulaProveedor
FROM
	[dbo].[dimContratos] contratos
	INNER JOIN [dbo].[dimProcedimientos] procedimientos
		ON contratos.procedimiento=procedimientos.idProcedimiento
	INNER JOIN [dbo].[dimInstituciones] instituciones
		ON contratos.institucion = instituciones.idInstitucion
	INNER JOIN [dbo].[dimProveedores] proveedores
		ON contratos.proveedor=proveedores.idProveedor
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
				, instituciones.cedulaInstitucion as 'C�dula Instituci�n'
				,proveedores.nombreProveedor as 'Nombre Proveedor'
				, proveedores.cedulaProveedor as 'C�dula Proveedor'
				, proveedores.tipoProveedor as 'Tipo de Proveedor'
				,sanciones.tipoSancion as 'Tipo Sanci�n'
				,tiempoInicio.fecha as 'Fecha Inicio Sanci�n'
				,tiempoFinal.fecha as 'Fecha Final Sanci�n'
				, sanciones.numeroResolucion as 'N�mero de Resoluci�n'
				, sanciones.estadoSancion as 'Estado Sanci�n'
			FROM
				[dbo].[hechSanciones] sanciones
				INNER JOIN [dbo].[dimInstituciones] instituciones
					ON sanciones.institucion = instituciones.idInstitucion
				INNER JOIN [dbo].[dimProveedores] proveedores
					ON sanciones.proveedor= proveedores.idProveedor
				INNER JOIN [dbo].[dimTiempo] tiempoInicio
					ON sanciones.fechaInicioSancion= tiempoInicio.idTiempo
				INNER JOIN [dbo].[dimTiempo] tiempoFinal
					ON sanciones.fechaFinalSancion= tiempoInicio.idTiempo
END;
GO;


/*REQ-50 REMATES
  DESCRIPCION:Presenta detalle de las variables de procedimientos de remate.
              La informaci�n que se desea desplegar es la siguiente:
				�	C�dula de la instituci�n que realiz� el remate. 
				�	Nombre de la Instituci�n que realiz� el remate. 
				�	N�mero de procedimiento.
				�	N�mero de cartel.
				�	Tipo de procedimiento.
				�	Modalidad: remate.
				�	Fecha de apertura (dd/mm/aaaa).
				�	Fecha de invitaci�n (dd/mm/aaaa).
				�	Partida.
				�	L�nea.
*/
/*REQ-51 GIRO COMERCIAL DEL CONTRATISTA
  DESCRIPCION:Presenta el detalle de los contratistas que han sido adjudicado
			  para dar un servicio o bien u obra, corresponda al giro comercial
			  al cual est� registrado.
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
				�	Nombre de la Instituci�n
*/
/*REQ-63 EMPRESAS CON M�S OBJECIONES
  DESCRIPCI�N: Este reporte presenta las empresas con m�s objeciones y que obstruyen los procesos de compra
			   La informaci�n que se desea ver:
				*	Nombre del Proveedor
				*	Cedula del proveedor
				*	Objeci�n presentada
				*	Numero de procedimiento
				*	Descripci�n del procedimiento
				*	Cantidad  de objeciones presentadas por empresa (proveedor)
				*	Nombre de instituci�n a la que le presentaron la objeci�n
				*	C�dula de instituci�n a la que le presentaron la objeci�n
				*	Cantidad de objeciones presentadas por Instituci�n
*/
CREATE PROCEDURE REP_EmpresasMasObjeciones
AS
BEGIN
	SELECT
		proveedores.nombreProveedor AS "Nombre del proveedor"
		,proveedores.cedulaProveedor AS "C�dula del proveedor"
		,CONCAT(objeciones.tipoRecurso, ' a la linea ',objeciones.lineaObjetada) AS "Objeci�n presentada"
		,procedimientos.numeroProcedimiento AS "N�mero de procedimiento"
		,procedimientos.descripcionProcedimiento AS "Descripci�n del procedimiento"
		,instituciones.nombreInstitucion AS "Nombre de la instituci�n"
		,instituciones.cedulaInstitucion AS "C�dula de la instituci�n"
	FROM [dbo].[hechObjeciones] objeciones 
		INNER JOIN [dbo].[dimProcedimientos] procedimientos
			ON objeciones.procedimiento = procedimientos.idProcedimiento
		INNER JOIN [dbo].[dimInstituciones] instituciones
			ON procedimientos.institucion = instituciones.idInstitucion
		INNER JOIN [dbo].[dimProveedores] proveedores
			ON objeciones.proveedor = proveedores.idProveedor
END
GO

