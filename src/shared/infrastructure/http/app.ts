/* eslint-disable no-console */
import express, { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import routes from './routes';
import DomainError from '@/shared/errors/domain-error';
import { NotFoundError } from '@/shared/application/errors/not-found-error';
import ApplicationError from '@/shared/errors/application-error';
import { auth, requiresAuth } from 'express-openid-connect';
import { prismaService } from '../database/prisma/prisma.service';
import session from 'express-session';
import ensureSingleSession from './middlewares/ensureSingleSession';
import { env } from '../env-config/env';

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(
  session({
    secret: 'your-session-secret', // Substitua pelo seu segredo
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false, httpOnly: true },
  }),
);

const config = {
  authRequired: false,
  auth0Logout: true,
  secret: env.AUTH0_SECRET,
  baseURL: env.AUTH0_BASE_URL,
  clientID: env.AUTH0_CLIENT_ID,
  issuerBaseURL: env.AUTH0_ISSUER_BASE_URL,
  afterCallback: async (req: Request, res: Response, session: any) => {
    console.log(session);
    const idToken = session.id_token;

    if (!idToken) {
      throw new Error('ID token not found in session');
    }

    const decodedToken: any = jwt.decode(idToken);
    console.log(decodedToken);
    if (!decodedToken) {
      throw new Error('Failed to decode ID token');
    }

    const user = {
      sub: decodedToken.sub,
      name: decodedToken.name,
      email: decodedToken.email,
    };

    const existingUser = await prismaService.user.findUnique({
      where: { auth0_id: user.sub },
    });

    if (!existingUser) {
      await prismaService.user.create({
        data: {
          auth0_id: user.sub,
          name: user.name,
          email: user.email,
        },
      });
    }

    await prismaService.session.deleteMany({
      where: { user_id: existingUser.id },
    });

    const sessionExpiry = new Date(decodedToken.exp * 1000);

    await prismaService.session.create({
      data: {
        user_id: existingUser.id,
        session_ip: req.ip,
        token: idToken,
        expires_at: sessionExpiry,
      },
    });

    session.sessionToken = idToken;
    req.session.token = idToken;
    req.session.expires_at = sessionExpiry;

    return session;
  },
};

app.use(auth(config));

routes.get('/', (req, res) => {
  return res.json({ message: 'Hello World!' });
});

app.get('/login', (req, res) => {
  res.oidc.login({ returnTo: 'http://localhost:3333/profile' });
});

app.use(ensureSingleSession);

app.use(routes);
app.get('/profile', (req, res) => {
  res.json(req.oidc.user);
});
app.get('/logout', (req, res) => {
  res.oidc.logout({ returnTo: 'https://localhost:3333/login' });
  res.clearCookie('connect.sid'); // 'connect.sid' é o nome padrão do cookie da sessão

  // Redireciona para a página de login
  res.redirect('https://localhost:3333/login');
});
app.use((req: Request, res: Response, next: NextFunction) => {
  next(new NotFoundError(`Cannot find ${req.originalUrl} on this server`));
});

app.use(
  (error: Error, request: Request, response: Response, next: NextFunction) => {
    if (error instanceof ApplicationError || error instanceof DomainError) {
      return response.status(error.statusCode).json({
        status: 'error',
        message: error.message,
        name: error.name,
      });
    }
    console.log(error);
    return response.status(500).json({
      status: 'error',
      message: 'Internal server error',
      err: error,
    });
  },
);

export { app };
