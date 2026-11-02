import jwt from 'jsonwebtoken';

export function signToken(userId: number, email: string) {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error('JWT_SECRET is not configured');
  }

  const expiresInSeconds = Number(process.env.JWT_EXPIRES_IN_SECONDS ?? 60 * 60 * 24 * 7);

  return jwt.sign({ sub: userId, email }, secret, {
    expiresIn: expiresInSeconds,
  });
}
