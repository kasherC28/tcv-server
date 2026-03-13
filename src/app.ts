import express from 'express';
import compression from 'compression';
import cors from 'cors';
import helmet from 'helmet';
import hpp from 'hpp';
import authRoutes from './modules/auth/auth.routes';
import usersRoutes from './modules/users/users.routes';
import salesRoutes from './modules/sales/sales.routes';
import contactRoutes from './modules/contact/contact.routes';
import productsRoutes from './modules/products/products.routes';
import checkoutRoutes from './modules/checkout/checkout.routes';
import siteRoutes from './modules/site/site.routes';
import { globalLimiter } from './middleware/rate-limit';
import { requestLogger } from './middleware/request-logger';
import { notFoundHandler } from './middleware/not-found';
import { errorHandler } from './middleware/error-handler';
import { env } from './config/env';

export const app = express();

app.disable('x-powered-by');
app.use(requestLogger);
app.use(helmet());
app.use(hpp());
app.use(compression());
app.use(globalLimiter);
app.use(cors({ origin: env.CORS_ORIGIN === '*' ? true : env.CORS_ORIGIN }));
app.use(express.json({ limit: '100kb' }));
app.use(express.urlencoded({ extended: false }));

app.get('/health', (_, res) => res.json({ success: true, message: 'ok' }));
app.use('/api/auth', authRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/sales', salesRoutes);
app.use('/api/contact-us', contactRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/checkout', checkoutRoutes);
app.use('/api/site', siteRoutes);

app.use(notFoundHandler);
app.use(errorHandler);
