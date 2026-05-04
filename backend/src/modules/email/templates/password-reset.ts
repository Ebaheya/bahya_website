function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export function buildPasswordResetEmail(
  resetUrl: string,
  userName: string
): { subject: string; html: string } {
  const safeUrl = escapeHtml(resetUrl);
  const safeName = escapeHtml(userName);

  return {
    subject: 'Reset your Bahya password',
    html: `
      <div style="font-family: Arial, sans-serif; color: #1f2933; line-height: 1.5; max-width: 560px;">
        <h1 style="font-size: 22px; margin: 0 0 16px;">Password reset request</h1>
        <p style="margin: 0 0 16px;">Hello ${safeName},</p>
        <p style="margin: 0 0 20px;">Use the button below to reset your password. This link expires soon and can be used once.</p>
        <p style="margin: 0 0 20px;">
          <a href="${safeUrl}" style="background: #2563eb; border-radius: 6px; color: #ffffff; display: inline-block; font-weight: 700; padding: 12px 18px; text-decoration: none;">
            Reset password
          </a>
        </p>
        <p style="margin: 0 0 12px;">If the button does not work, paste this link into your browser:</p>
        <p style="margin: 0; word-break: break-all;">
          <a href="${safeUrl}" style="color: #2563eb;">${safeUrl}</a>
        </p>
      </div>
    `,
  };
}
