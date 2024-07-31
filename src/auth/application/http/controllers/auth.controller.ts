import { Request, Response } from 'express';
import passport from 'passport';

export const googleAuth = passport.authenticate('google', {
  scope: ['profile', 'email'],
});

export const googleAuthCallback = passport.authenticate('google', {
  failureRedirect: '/',
});

export const authRedirect = (req: Request, res: Response) => {
  res.redirect('/');
};
