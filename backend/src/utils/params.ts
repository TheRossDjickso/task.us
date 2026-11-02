import { AppError } from './errors.js';

export function parseId(value: string | string[] | undefined, name = 'id'): number {
  const raw = Array.isArray(value) ? value[0] : value;
  const id = Number(raw);

  if (!Number.isInteger(id) || id <= 0) {
    throw new AppError(400, `Invalid ${name}`);
  }

  return id;
}
