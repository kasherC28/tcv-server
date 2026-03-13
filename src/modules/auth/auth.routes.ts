import { Router } from 'express';
import { asyncWrap } from '../../common/http';
import { Role } from '../../common/enums';
import { auth } from '../../middleware/auth';
import { allowRoles } from '../../middleware/role';
import { authLimiter } from '../../middleware/rate-limit';
import { validate } from '../../middleware/validate';
import * as controller from './auth.controller';
import { blockUserSchema, createUserSchema, forgotPasswordSchema, resetPasswordSchema, signinSchema, signupSchema, updatePasswordSchema } from './auth.schema';
import { idParamSchema } from '../users/users.schema';

const router = Router();

router.post('/signup', authLimiter, validate(signupSchema), asyncWrap(controller.signup));
router.post('/signin', authLimiter, validate(signinSchema), asyncWrap(controller.signin));
router.post('/forgot-password', authLimiter, validate(forgotPasswordSchema), asyncWrap(controller.forgotPassword));
router.post('/reset-password', authLimiter, validate(resetPasswordSchema), asyncWrap(controller.resetPassword));
router.post('/update-password', auth, validate(updatePasswordSchema), asyncWrap(controller.updatePassword));
router.post('/users', auth, allowRoles(Role.ADMIN), validate(createUserSchema), asyncWrap(controller.createUser));
router.patch('/users/:id/block', auth, allowRoles(Role.ADMIN), validate(idParamSchema, 'params'), validate(blockUserSchema), asyncWrap(controller.blockUser));

export default router;
