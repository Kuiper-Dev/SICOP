USE dw_sicop

CREATE TABLE dimProveedores(
	idProveedor BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaProveedor VARCHAR(30) NOT NULL,
	nombreProveedor VARCHAR(200) NOT NULL,
	tipoProveedor VARCHAR(50) NOT NULL,
	tamanoProveedor VARCHAR(30) NOT NULL,
	provinciaProveedor VARCHAR(30) NOT NULL,
	cantonProveedor VARCHAR(30) NOT NULL,
	distritoProveedor VARCHAR(30) NOT NULL,
	fechaConstitucion DATE NOT NULL,
	fechaRegistro DATE NOT NULL
)

CREATE TABLE dimInstituciones(
	idInstitucion BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaInstitucion VARCHAR(30) NOT NULL,
	nombreInstitucion VARCHAR(200) NOT NULL,
	provinciaInstitucion VARCHAR(30) NOT NULL,
	cantonInstitucion VARCHAR(30) NOT NULL,
	distritoInstitucion VARCHAR(30) NOT NULL,
	fechaIngreso DATE NOT NULL
)

CREATE TABLE dimClasificacionProductos(
	idClasificacionProducto BIGINT PRIMARY KEY IDENTITY(1,1),
	codigoClasificacion VARCHAR(8) NOT NULL,
	codigoIdentificacion VARCHAR(8) NOT NULL,
	descripcionClasificacion VARCHAR(600) NOT NULL
)

CREATE TABLE dimProductos(
	idProducto BIGINT PRIMARY KEY IDENTITY(1,1),
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(4000) NOT NULL,
	fechaRegistro DATE NOT NULL,
	clasificacionProducto BIGINT NOT NULL,
	CONSTRAINT fk_dimProductos_dimClasificacionProductos FOREIGN KEY (clasificacionProducto)
		REFERENCES dimClasificacionProductos(idClasificacionProducto)
)

CREATE TABLE dimProcedimientos(
	idProcedimiento BIGINT PRIMARY KEY IDENTITY(1,1),
	numeroProcedimiento VARCHAR(50) NOT NULL,
	tipoProcedimiento VARCHAR(50) NOT NULL,
	modalidadProcedimiento VARCHAR(100) NOT NULL,
	descripcionProcedimiento VARCHAR(200) NOT NULL,
	descripcionExcepcion VARCHAR(1000) NOT NULL,
	codigoExcepcion VARCHAR(8) NOT NULL,
	estadoProcedimiento VARCHAR(30) NOT NULL,
	codigoBPIP VARCHAR(20) NOT NULL,
	clasificacion VARCHAR(50) NOT NULL,
	nroSICOP varchar(11) NOT NULL
)

CREATE TABLE dimTiempo(
	idTiempo BIGINT PRIMARY KEY IDENTITY(1,1),
	fecha DATE NOT NULL,
	dia SMALLINT NOT NULL,
	mes SMALLINT NOT NULL,
	ano SMALLINT NOT NULL,
	trimestre SMALLINT NOT NULL,
	semestre SMALLINT NOT NULL,
	semana SMALLINT NOT NULL,
	diaAno SMALLINT NOT NULL,
	diaSemana SMALLINT NOT NULL
)


CREATE TABLE dimMonedas(
	idMoneda INTEGER PRIMARY KEY IDENTITY(1,1),
	descripcionMoneda VARCHAR(40) NOT NULL,
	codigoISO VARCHAR(3) NOT NULL
)

CREATE TABLE dimRepresentantes(
	idRepresentante BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaRepresentante VARCHAR(30) NOT NULL,
	nombreRepresentante VARCHAR(100) NOT NULL
)

CREATE TABLE dimFuncionarios(
	idFuncionario BIGINT PRIMARY KEY IDENTITY(1,1),
	cedulaFuncionario VARCHAR(30) NOT NULL,
	nombreFuncionario VARCHAR(100) NOT NULL
)

CREATE TABLE dimContratos(
	idContrato BIGINT PRIMARY KEY IDENTITY(1,1),
	numeroContrato VARCHAR(20) NOT NULL,
	procedimiento BIGINT NOT NULL,
	institucion BIGINT NOT NULL,
	proveedor BIGINT NOT NULL
	CONSTRAINT fk_dimContratos_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_dimContratos_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_dimContratos_dimProveedor FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor)
)

CREATE TABLE hechCarteles(	
	institucion BIGINT NOT NULL,
	fechaPublicacion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	fechaApertura BIGINT NOT NULL,
	clasificacionProducto BIGINT NOT NULL,
	moneda INTEGER NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	numeroPartida SMALLINT NOT NULL,
	cantidadSolicitada INTEGER NOT NULL,
	precioUnitarioEstimado MONEY NOT NULL,
	montoReservado MONEY NOT NULL,
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	--CONSTRAINT pk_hechCarteles PRIMARY KEY (institucion, fechaPublicacion,
		--procedimiento, fechaApertura, clasificacionProducto, moneda),
	CONSTRAINT fk_hechCarteles_dimInstituciones FOREIGN KEY (institucion) 
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechCarteles_dimTiempoP FOREIGN KEY (fechaPublicacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCarteles_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechCarteles_dimTiempoA FOREIGN KEY (fechaApertura) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCarteles_dimClasificacionProductos FOREIGN KEY (clasificacionProducto)
		REFERENCES dimClasificacionProductos(idClasificacionProducto),
	CONSTRAINT fk_hechCarteles_dimMonedas FOREIGN KEY (moneda) 
		REFERENCES dimMonedas(idMoneda)	
)

CREATE TABLE hechInvitaciones(
	institucion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaInvitacion BIGINT NOT NULL,
	secuencia VARCHAR(20) NOT NULL,
	--CONSTRAINT pk_hechInvitaciones PRIMARY KEY (institucion,procedimiento,
		--proveedor,fechaInvitacion),
	CONSTRAINT fk_hechosInvitaciones_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechosInvitaciones_dimProcedimientos FOREIGN KEY (procedimiento)
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechosInvitaciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechosInvitaciones_dimTiempo FOREIGN KEY (fechaInvitacion)
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechOfertas(	
	proveedor BIGINT NOT NULL,
	fechaPresentacion BIGINT NOT NULL,
	procedimiento BIGINT NOT NULL,
	producto BIGINT NOT NULL,
	moneda INTEGER NOT NULL,
	tipoOferta VARCHAR(30) NOT NULL,
	numeroLinea SMALLINT NOT NULL,
	numeroOferta VARCHAR(50) NOT NULL,
	cantidadOfertada INTEGER NOT NULL,
	precioUnitarioOfertado MONEY NOT NULL,
	descuento MONEY NOT NULL,
	IVAUnidad MONEY NOT NULL,
	acarreos MONEY NOT NULL,
	IVAAcarreos MONEY NOT NULL,
	otrosImpuestos MONEY NOT NULL,	
	tipoCambioCRC MONEY NOT NULL,
	tipoCambioUSD MONEY NOT NULL,
	montoTotal MONEY NOT NULL,
	--CONSTRAINT pk_hechOfertas PRIMARY KEY (proveedor, fechaPresentacion,
		--procedimiento, producto, moneda),
	CONSTRAINT fk_hechOfertas_dimProveedores FOREIGN KEY (proveedor) 
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechOfertas_dimTiempo FOREIGN KEY (fechaPresentacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechOfertas_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento),
	CONSTRAINT fk_hechOfertas_dimProductos FOREIGN KEY (producto) 
		REFERENCES dimProductos(idProducto),	
	CONSTRAINT fk_hechOfertas_dimMonedas FOREIGN KEY (moneda) 
		REFERENCES dimMonedas(idMoneda)	
)

CREATE TABLE hechCriteriosEvaluacion(
	procedimiento BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	factorEvaluar VARCHAR(300) NOT NULL,
	porcentajeEvaluacion decimal(6,3) NOT NULL,		
	--CONSTRAINT pk_hechCriteriosEvaluacion PRIMARY KEY (proveedor, fechaRegistro),	
	CONSTRAINT fk_hechCriteriosEvaluacion_dimTiempo FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechCriteriosEvaluacion_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento)
)

CREATE TABLE hechSanciones(
	institucion BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	fechaInicioSancion BIGINT NOT NULL,
	fechaFinalSancion BIGINT NOT NULL,
	codigoProducto VARCHAR(8) NOT NULL,
	descripcionProducto VARCHAR(200) NOT NULL,
	tipoSancion	VARCHAR(30) NOT NULL,
	descripcionSancion VARCHAR(1000),
	estadoSancion VARCHAR(3) NOT NULL,
	numeroResolucion VARCHAR(30) NOT NULL,
	--CONSTRAINT pk_hechSanciones PRIMARY KEY (institucion, proveedor, fechaRegistro
		--fechaInicioSancion, fechaFinalSancion),	
	CONSTRAINT fk_hechSanciones_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechSanciones_dimProveedores FOREIGN KEY (proveedor)
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechSanciones_dimTiempoR FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechSanciones_dimTiempoI FOREIGN KEY (fechaInicioSancion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechSanciones_dimTiempoF FOREIGN KEY (fechaFinalSancion) 
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechInhibicionesFuncionario(
	institucion BIGINT NOT NULL,
	funcionario BIGINT NOT NULL,
	fechaRegistro BIGINT NOT NULL,
	fechaInicioInhibicion BIGINT NOT NULL,
	fechaFinalInhibicion BIGINT NOT NULL,		
	estadoInhibicion VARCHAR(3) NOT NULL,	
	--CONSTRAINT pk_hechSanciones PRIMARY KEY (institucion, funcionario, fechaRegistro
		--fechaInicioInhibicion, fechaFinalInhibicion),	
	CONSTRAINT fk_hechInhibicionesFuncionario_dimInstituciones FOREIGN KEY (institucion)
		REFERENCES dimInstituciones(idInstitucion),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimFuncionarios FOREIGN KEY (funcionario)
		REFERENCES dimFuncionarios(idFuncionario),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoR FOREIGN KEY (fechaRegistro) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoI FOREIGN KEY (fechaInicioInhibicion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechInhibicionesFuncionario_dimTiempoF FOREIGN KEY (fechaFinalInhibicion) 
		REFERENCES dimTiempo(idTiempo)
)

CREATE TABLE hechObjeciones(	
	procedimiento BIGINT NOT NULL,
	proveedor BIGINT NOT NULL,
	fechaPresentacion BIGINT NOT NULL,
	numeroRecurso INTEGER NOT NULL,
	numeroActo SMALLINT NOT NULL,
	lineaObjetada SMALLINT NOT NULL,
	tipoRecurso VARCHAR(10) NOT NULL,
	estadoRecurso VARCHAR(2) NOT NULL,
	resultado VARCHAR(30) NOT NULL,
	causaResultado VARCHAR(100) NOT NULL,
	nombreRecurrente VARCHAR(100) NOT NULL,	
	--CONSTRAINT pk_hechOfertas PRIMARY KEY (procedimiento, proveedor, fechaPresentacion),
	CONSTRAINT fk_hechObjeciones_dimProveedores FOREIGN KEY (proveedor) 
		REFERENCES dimProveedores(idProveedor),
	CONSTRAINT fk_hechObjeciones_dimTiempo FOREIGN KEY (fechaPresentacion) 
		REFERENCES dimTiempo(idTiempo),
	CONSTRAINT fk_hechObjeciones_dimProcedimientos FOREIGN KEY (procedimiento) 
		REFERENCES dimProcedimientos(idProcedimiento)	
)

---- FINAL SCRIPT ---












