import {Router} from 'express';
import { getProveedores } from '../controllers/proveedores.controllers';
import { getProveedoresAdjudicados } from '../controllers/proveedores.controllers';
import { getProveedoresSancionados } from '../controllers/proveedores.controllers';
const router=Router();

router.get('/proveedores', getProveedores);
router.get('/proveedores/adjudicados', getProveedoresAdjudicados);
router.get('/proveedores/sancionados', getProveedoresSancionados);
export default router