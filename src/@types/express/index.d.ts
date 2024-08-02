declare namespace Express {
  export interface Request {
    session: {
      token?: string;
      expires_at?: Date;
    };
  }
}
