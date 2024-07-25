import DomainError from '../errors/domain-error';

export class ConflictError extends DomainError {
  constructor(public message: string) {
    super(message, 409);
    this.name = 'ConflictError';
  }
}
