import rateLimit from 'express-rate-limit';
import { sendError } from '../utils/response.js';

const createLimiter = (windowMs, max, message) =>
  rateLimit({
    windowMs, max,
    standardHeaders: true, legacyHeaders: false,
    handler: (req, res) => sendError(res, 429, message || 'Too many requests. Please try again later.'),
  });

export const apiLimiter = createLimiter(
  parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  parseInt(process.env.RATE_LIMIT_MAX) || 100,
  'Too many requests. Please try again in 15 minutes.'
);

export const authLimiter = createLimiter(
  15 * 60 * 1000,
  20,
  'Too many authentication attempts. Please try again in 15 minutes.'
);
