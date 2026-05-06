import { env } from '../../config/env';
import { emailTransport } from '../../config/email';
import { logger } from '../../config/logger';
import { AppError } from '../../utils/httpError';

export async function sendEmail(to: string, subject: string, html: string): Promise<void> {
  try {
    await emailTransport.sendMail({
      from: env.SMTP_FROM,
      to,
      subject,
      html,
    });
  } catch (err) {
    const recipientDomain = to.split('@')[1] ?? null;
    logger.error(
      { err, recipientDomain, subject, metric: 'email_send_failure' },
      'email send failed'
    );
    throw AppError.emailDeliveryFailed();
  }
}
