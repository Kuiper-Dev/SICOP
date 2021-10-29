import {Router} from 'express';
import { getInstitucionesSICOP } from '../controllers/instituciones.controllers';

const router=Router();

router.get('/instituciones', getInstitucionesSICOP);

export default router