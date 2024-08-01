import authRoutes from '@/auth/application/http/routes/auth.routes';
import { InvalidCredentialsError } from '@/shared/application/errors/invalid-credentials-error';
import { Router } from 'express';
import { ensureAuthenticated } from './middlewares';

const routes = Router();

routes.get('/', (req, res) => {
  return res.json({ message: 'Hello World!' });
});

routes.get('/credentials', (req, res) => {
  throw new InvalidCredentialsError('rota para teste de erro credentials');
});

routes.use('/auth', authRoutes);

export default routes;
