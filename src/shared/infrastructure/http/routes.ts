import { InvalidCredentialsError } from '@/shared/application/errors/invalid-credentials-error';
import { Router } from 'express';

const routes = Router();

routes.get('/credentials', (req, res) => {
  throw new InvalidCredentialsError('rota para teste de erro credentials');
});

export default routes;
