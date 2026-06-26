/** Standardized API response helpers */

export const sendSuccess = (res, statusCode = 200, message = 'Operation successful', data = {}) => {
  return res.status(statusCode).json({ success: true, message, data });
};

export const sendError = (res, statusCode = 500, message = 'Operation failed', errors = []) => {
  return res.status(statusCode).json({
    success: false,
    message,
    errors: Array.isArray(errors) ? errors : [errors],
  });
};

export const sendPaginated = (res, message, data, pagination) => {
  return res.status(200).json({ success: true, message, data, pagination });
};
