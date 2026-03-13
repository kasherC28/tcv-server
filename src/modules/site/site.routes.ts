import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import * as controller from './site.controller';

const router = Router();

router.get('/config', asyncWrap(controller.getConfig));

export default router;
