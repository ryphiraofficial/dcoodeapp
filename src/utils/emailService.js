import nodemailer from 'nodemailer';

const createTransporter = () => {
  // If no SMTP settings are provided, use ethereal email for testing
  if (!process.env.SMTP_HOST) {
    console.warn('⚠️ SMTP credentials not configured. Email will not be sent in production.');
  }

  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.ethereal.email',
    port: parseInt(process.env.SMTP_PORT) || 587,
    secure: process.env.SMTP_PORT === '465', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
};

/**
 * Send an email using nodemailer
 * @param {string} to - Recipient email address
 * @param {string} subject - Email subject
 * @param {string} html - HTML body of the email
 */
export const sendEmail = async ({ to, subject, html }) => {
  try {
    const transporter = createTransporter();
    const mailOptions = {
      from: process.env.SMTP_FROM || '"Dcoode" <no-reply@dcoode.com>',
      to,
      subject,
      html,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ Email sent to ${to} (Message ID: ${info.messageId})`);
    
    // For ethereal email testing, you can see the URL here
    if (info.messageId && !process.env.SMTP_HOST) {
      console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));
    }
    
    return info;
  } catch (error) {
    console.error('❌ Failed to send email:', error);
    // Don't throw the error, we don't want to break the student creation process
    // if the email fails to send (e.g. invalid credentials).
    // Just log it.
  }
};
