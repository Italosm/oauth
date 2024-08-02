import { NextFunction, Request, Response } from 'express';
import { prismaService } from '../../database/prisma/prisma.service';
import { requiresAuth } from 'express-openid-connect';

export default async function ensureSingleSession(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  requiresAuth()(req, res, async () => {
    try {
      // Obtenha o token do id_token
      const sessionToken = req.oidc.idToken; // Ajuste conforme a forma como você obtém o token

      if (!sessionToken) {
        return res.redirect('/login'); // Redireciona para login se o token não estiver presente
      }

      // Obtenha a sessão do banco de dados usando o token
      const userSession = await prismaService.session.findUnique({
        where: {
          token: sessionToken,
        },
      });

      // Verifique se a sessão é válida
      if (!userSession || userSession.expires_at < new Date()) {
        return res.redirect('/login'); // Redireciona para login se a sessão não for encontrada ou estiver expirada
      }

      // Se tudo estiver correto, prossiga com a requisição
      return next();
    } catch (error) {
      console.error('Error in ensureSingleSession middleware:', error);
      return res.redirect('/login'); // Redireciona para login em caso de erro
    }
  });
}
