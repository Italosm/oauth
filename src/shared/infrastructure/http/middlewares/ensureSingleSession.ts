/* eslint-disable no-console */
import { NextFunction, Request, Response } from 'express';
import { prismaService } from '../../database/prisma/prisma.service';
import { requiresAuth } from 'express-openid-connect';

export default async function ensureSingleSession(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  requiresAuth()(req, res, async () => {
    // Obtenha o token do id_token
    const sessionId = req.session?.id; // Ajuste conforme a forma como você obtém o token
    const idToken = req.oidc.idToken;
    const userRequest = req.oidc.user;

    const user = await prismaService.user.findUnique({
      where: {
        auth0_id: userRequest.sub,
      },
    });
    if (user) {
      if (sessionId) {
        // Obtenha a sessão do banco de dados
        const userSession = await prismaService.session.findUnique({
          where: {
            user_id: user.id,
          },
        });
        if (userSession) {
          if (userSession.session_id != idToken) {
            console.log('Deslogado pelo middleware');
            return res.oidc.logout({ returnTo: '/login' });
          }
        }
      }
    }
    // Se tudo estiver correto, prossiga com a requisição
    return next();
  });
}
