import {Router} from 'express';
import { getSancionesProveedores } from '../controllers/sanciones.controllers';

const router=Router();

router.get('/sanciones/proveedores', getSancionesProveedores);

export default router