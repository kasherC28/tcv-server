import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import * as controller from './products.controller';

const router = Router();

router.get('/', asyncWrap(controller.list));

export default router;
