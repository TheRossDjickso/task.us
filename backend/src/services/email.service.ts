import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: Number(process.env.SMTP_PORT ?? 587),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

export async function sendPasswordResetEmail(email: string, token: string) {
  const frontendUrl = process.env.FRONTEND_URL ?? 'http://localhost:5173';
  const resetUrl = `${frontendUrl}/reset-password?token=${token}`;

  if (!process.env.SMTP_HOST) {
    console.log(`[dev] Password reset link for ${email}: ${resetUrl}`);
    return;
  }

  await transporter.sendMail({
    from: process.env.SMTP_FROM ?? process.env.SMTP_USER,
    to: email,
    subject: 'Réinitialisation de votre mot de passe',
    html: `
      <p>Vous avez demandé une réinitialisation de mot de passe.</p>
      <p><a href="${resetUrl}">Cliquez ici pour réinitialiser</a></p>
      <p>Ce lien expire dans 1 heure.</p>
    `,
  });
}
