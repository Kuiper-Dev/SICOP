import express from 'express';
import config from '../config/config';
import procedimientosRoutes from '../routes/procedimientos.routes';
import cartelesRoutes from '../routes/carteles.routes';
import proveedoresRoutes from '../routes/proveedores.routes';
import contratosRoutes from '../routes/contratos.routes';
import sancionesRoutes from '../routes/sanciones.routes';
import institucionesRoutes from '../routes/instituciones.routes'
import jsonRoutes from '../routes/json.routes';
const app= express();
let port;
app.set('port',config.port);


app.use(cartelesRoutes);
app.use(contratosRoutes);
app.use(institucionesRoutes);
app.use(procedimientosRoutes);
app.use(proveedoresRoutes);
app.use(sancionesRoutes);
app.use(jsonRoutes);
export default app