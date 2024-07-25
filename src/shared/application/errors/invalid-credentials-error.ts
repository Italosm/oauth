import ApplicationError from '../../errors/application-error';

export class InvalidCredentialsError extends ApplicationError {
  constructor(public message: string) {
    super(message, 401);
    this.name = 'InvalidCredentialsError';
  }
}
