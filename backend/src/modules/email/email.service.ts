import { env } from '../../config/env';
import { emailTransport } from '../../config/email';
import { logger } from '../../config/logger';

export async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  try {
    await emailTransport.sendMail({
      from: env.SMTP_FROM,
      to,
      subject,
      html,
    });
  } catch (err) {
    logger.error({ err, to, subject, metric: 'email_send_failure' }, 'email send failed');
  }
}
