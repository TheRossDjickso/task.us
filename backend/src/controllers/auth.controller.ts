import bcrypt from 'bcrypt';
import crypto from 'node:crypto';
import type { Request, Response } from 'express';
import { z } from 'zod';
import { User } from '../models/index.js';
import { sendPasswordResetEmail } from '../services/email.service.js';
import { AppError } from '../utils/errors.js';
import { signToken } from '../utils/jwt.js';

const registerSchema = z.object({
  full_name: z.string().min(1).max(100),
  email: z.string().email().max(150),
  password: z.string().min(8).max(128),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const forgotPasswordSchema = z.object({
  email: z.string().email(),
});

const resetPasswordSchema = z.object({
  token: z.string().min(1),
  password: z.string().min(8).max(128),
});

function sanitizeUser(user: User) {
  return {
    id: user.id,
    full_name: user.full_name,
    email: user.email,
    avatar_url: user.avatar_url,
    created_at: user.created_at,
  };
}

export async function register(req: Request, res: Response) {
  const body = registerSchema.parse(req.body);

  const existing = await User.findOne({ where: { email: body.email } });
  if (existing) {
    throw new AppError(409, 'Email already in use');
  }

  const password_hash = await bcrypt.hash(body.password, 12);
  const user = await User.create({
    full_name: body.full_name,
    email: body.email,
    password_hash,
  });

  const token = signToken(user.id, user.email);
  res.status(201).json({ user: sanitizeUser(user), token });
}

export async function login(req: Request, res: Response) {
  const body = loginSchema.parse(req.body);

  const user = await User.findOne({ where: { email: body.email } });
  if (!user) {
    throw new AppError(401, 'Invalid credentials');
  }

  const valid = await bcrypt.compare(body.password, user.password_hash);
  if (!valid) {
    throw new AppError(401, 'Invalid credentials');
  }

  const token = signToken(user.id, user.email);
  res.json({ user: sanitizeUser(user), token });
}

export async function forgotPassword(req: Request, res: Response) {
  const body = forgotPasswordSchema.parse(req.body);

  const user = await User.findOne({ where: { email: body.email } });
  if (!user) {
    res.json({ message: 'If the email exists, a reset link has been sent' });
    return;
  }

  const token = crypto.randomBytes(32).toString('hex');
  const expires = new Date(Date.now() + 60 * 60 * 1000);

  await user.update({
    password_reset_token: token,
    password_reset_expires: expires,
  });

  await sendPasswordResetEmail(user.email, token);
  res.json({ message: 'If the email exists, a reset link has been sent' });
}

export async function resetPassword(req: Request, res: Response) {
  const body = resetPasswordSchema.parse(req.body);

  const user = await User.findOne({
    where: { password_reset_token: body.token },
  });

  if (
    !user ||
    !user.password_reset_expires ||
    user.password_reset_expires < new Date()
  ) {
    throw new AppError(400, 'Invalid or expired reset token');
  }

  const password_hash = await bcrypt.hash(body.password, 12);
  await user.update({
    password_hash,
    password_reset_token: null,
    password_reset_expires: null,
  });

  res.json({ message: 'Password reset successfully' });
}

export async function getMe(req: Request, res: Response) {
  if (!req.user) {
    throw new AppError(401, 'Not authenticated');
  }
  res.json({
    id: req.user.id,
    full_name: req.user.full_name,
    email: req.user.email,
  });
}
