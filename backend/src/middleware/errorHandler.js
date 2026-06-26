import { sendError } from '../utils/response.js';

// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  console.error('❌ Error:', err.message);

  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    const value = err.keyValue[field];
    return sendError(res, 409, `Duplicate value: '${value}' already exists for field '${field}'.`);
  }
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map((e) => e.message);
    return sendError(res, 400, 'Validation failed', errors);
  }
  if (err.name === 'CastError') return sendError(res, 400, `Invalid ${err.path}: ${err.value}`);
  if (err.name === 'JsonWebTokenError') return sendError(res, 401, 'Invalid token');
  if (err.name === 'TokenExpiredError') return sendError(res, 401, 'Token expired');
  if (err.code === 'LIMIT_FILE_SIZE') return sendError(res, 400, 'File too large. Maximum 5MB allowed.');
  if (err.code === 'LIMIT_UNEXPECTED_FILE') return sendError(res, 400, 'Unexpected file field.');

  return sendError(res, err.statusCode || 500, err.message || 'Internal server error');
};

export default errorHandler;
