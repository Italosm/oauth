/* eslint-disable no-console */
import express, { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import routes from './routes';
import DomainError from '@/shared/errors/domain-error';
import { NotFoundError } from '@/shared/application/errors/not-found-error';
import ApplicationError from '@/shared/errors/application-error';
import { auth, requiresAuth } from 'express-openid-connect';
import { prismaService } from '../database/prisma/prisma.service';
import { env } from '../env-config/env';
import session from 'express-session';
import ensureSingleSession from './middlewares/ensureSingleSession';

const app = express();

app.use(express.json());

app.use(
  session({
    secret: 'Make sure to add SESSION_SECRET to your .env file', // Make sure to add SESSION_SECRET to your .env file
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: true,
      httpOnly: true,
      maxAge: 24 * 60 * 60 * 1000,
    },
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
    const idToken = session.id_token;

    if (!idToken) {
      throw new Error('ID token not found in session');
    }

    const decodedToken: any = jwt.decode(idToken);

    if (!decodedToken) {
      throw new Error('Failed to decode ID token');
    }
    const user = {
      sub: decodedToken.sub,
      name: decodedToken.name,
      email: decodedToken.email,
    };

    let existingUser = await prismaService.user.findUnique({
      where: { auth0_id: user.sub },
    });

    if (!existingUser) {
      existingUser = await prismaService.user.create({
        data: {
          auth0_id: user.sub,
          name: user.name,
          email: user.email,
        },
      });
    }

    if (existingUser) {
      const currentSession = await prismaService.session.findUnique({
        where: { user_id: existingUser.id },
      });
      if (currentSession) {
        if (currentSession.session_id == idToken) {
          console.log('idToken não é único');
        }
        await prismaService.recordSession.create({
          data: {
            user_id: currentSession.user_id,
            session_ip: currentSession.session_ip,
            session_id: currentSession.session_id,
            action: currentSession.action,
            created_at: currentSession.created_at,
            expired_in: currentSession.expires_at,
          },
        });

        await prismaService.session.delete({
          where: { user_id: existingUser.id },
        });
      }
    }
    const sessionExpiry = new Date(decodedToken.exp * 1000);
    await prismaService.session.create({
      data: {
        user_id: existingUser.id,
        session_ip: req.ip,
        session_id: idToken,
        expires_at: sessionExpiry,
      },
    });
    req.session.id = idToken;

    session.session_id = session.sid;
    return session;
  },
};

app.use(auth(config));

routes.get('/', (req, res) => {
  return res.json({ message: 'Hello World!' });
});

app.get('/login', (req, res) => {
  res.oidc.login({
    returnTo: 'http://localhost:3333/profile',
  });
});

app.use(ensureSingleSession);
app.use(routes);

app.get('/profile', requiresAuth(), (req, res) => {
  res.json({
    is_authenticated: req.oidc.isAuthenticated(),
    user: req.oidc.user,
  });
});
app.get('/sair', requiresAuth(), async (req, res) => {
  const auth0Id = req.oidc.user.sub;
  const user = await prismaService.user.findUnique({
    where: {
      auth0_id: auth0Id,
    },
  });

  const currentSession = await prismaService.session.findUnique({
    where: { user_id: user.id },
  });

  if (currentSession) {
    await prismaService.recordSession.create({
      data: {
        user_id: currentSession.user_id,
        session_ip: currentSession.session_ip,
        session_id: currentSession.session_id,
        created_at: currentSession.created_at,
        expired_in: currentSession.expires_at,
      },
    });
  }

  await prismaService.session.delete({
    where: { user_id: user.id },
  });
  res.oidc.logout({ returnTo: '/login' });
});

app.get('/logout', requiresAuth(), async (req, res) => {
  const auth0Id = req.oidc.user.sub;
  const user = await prismaService.user.findUnique({
    where: {
      auth0_id: auth0Id,
    },
  });

  const currentSession = await prismaService.session.findUnique({
    where: { user_id: user.id },
  });

  if (currentSession) {
    await prismaService.recordSession.create({
      data: {
        user_id: currentSession.user_id,
        session_ip: currentSession.session_ip,
        session_id: currentSession.session_id,
        created_at: currentSession.created_at,
        expired_in: currentSession.expires_at,
      },
    });
  }

  await prismaService.session.delete({
    where: { user_id: user.id },
  });
  res.oidc.logout({ returnTo: '/login' });
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
