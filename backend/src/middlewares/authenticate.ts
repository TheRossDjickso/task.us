import type { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/index.js';
import { AppError } from '../utils/errors.js';

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    throw new AppError(401, 'Authentication required');
  }

  const token = header.slice(7);
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new AppError(500, 'JWT_SECRET is not configured');
  }

  try {
    const decoded = jwt.verify(token, secret);
    if (typeof decoded === 'string' || !decoded || typeof decoded.sub !== 'number') {
      throw new AppError(401, 'Invalid token');
    }

    const user = await User.findByPk(decoded.sub, {
      attributes: ['id', 'email', 'full_name'],
    });

    if (!user || typeof decoded.email !== 'string') {
      throw new AppError(401, 'Invalid token');
    }

    req.user = {
      id: user.id,
      email: user.email,
      full_name: user.full_name,
    };
    next();
  } catch {
    throw new AppError(401, 'Invalid or expired token');
  }
}
