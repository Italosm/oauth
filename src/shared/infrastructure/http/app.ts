/* eslint-disable no-console */
import express, { NextFunction, Request, Response } from 'express';
import session from 'express-session';
// import passport from 'passport';
import routes from './routes';
import DomainError from '@/shared/errors/domain-error';
import { NotFoundError } from '@/shared/application/errors/not-found-error';
import ApplicationError from '@/shared/errors/application-error';
// import '@/auth/infrastructure/passport/strategies/google.strategy';
import { auth, requiresAuth } from 'express-openid-connect';

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(
  session({
    secret: 'SECRET',
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false },
  }),
);

// app.use(passport.initialize());
// app.use(passport.session());

app.use(routes);

const config = {
  authRequired: false,
  auth0Logout: true,
  secret: 'along,randomly-generatedstringstoredinenv',
  baseURL: 'http://localhost:3333',
  clientID: 'pzXo5r0cBWcwAIglZ56IuOFmkwwMz3Tn',
  issuerBaseURL: 'https://dev-se8sm2jwi4t0q7nu.us.auth0.com',
};

app.use(auth(config));

app.get('/login', (req, res) => {
  res.oidc.login();
});
app.get('/profile', requiresAuth(), (req, res) => {
  res.json(req.oidc.user);
});
app.get('/logout', (req, res) => {
  res.oidc.logout();
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
