import ApplicationError from '@/shared/errors/application-error';

export class NotFoundError extends ApplicationError {
  constructor(public message: string) {
    super(message, 404);
    this.name = 'NotFoundError';
  }
}
