import ApplicationError from '@/shared/errors/application-error';

export class BadRequestError extends ApplicationError {
  constructor(public message: string) {
    super(message, 400);
    this.name = 'BadRequestError';
  }
}
