import { Router } from 'express';
import {
  authRedirect,
  googleAuth,
  googleAuthCallback,
} from '../controllers/auth.controller';

const authRoutes = Router();

authRoutes.get('/google', googleAuth);
authRoutes.get('/google/callback', googleAuthCallback, authRedirect);

export default authRoutes;
