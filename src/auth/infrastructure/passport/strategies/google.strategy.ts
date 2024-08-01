import { env } from '@/shared/infrastructure/env-config/env';
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

// Simulação de armazenamento de usuários em memória
const users: { [key: string]: any } = {};

passport.serializeUser((user: any, done) => {
  done(null, user.id); // Armazena o ID do usuário na sessão
});

passport.deserializeUser((id: number, done) => {
  const user = users[id]; // Recupera o usuário da simulação de armazenamento
  done(null, user);
});

passport.use(
  new GoogleStrategy(
    {
      clientID: env.GOOGLE_CLIENT_ID!,
      clientSecret: env.GOOGLE_CLIENT_SECRET!,
      callbackURL: 'http://localhost:3333/auth/google/callback',
    },
    (token, tokenSecret, profile, done) => {
      // Simulação de criar ou atualizar usuário
      const user = {
        id: profile.id,
        name: profile.displayName,
        email: profile.emails[0].value,
      };

      users[user.id] = user; // Armazena o usuário na simulação
      return done(null, user);
    },
  ),
);
