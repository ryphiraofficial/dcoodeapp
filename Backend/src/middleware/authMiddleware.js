import { verifyAccessToken } from '../utils/jwtUtils.js';
import { sendError } from '../utils/response.js';
import Staff from '../models/Staff.js';
import Student from '../models/Student.js';

export const protect = async (req, res, next) => {
  try {
    let token;
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      token = authHeader.split(' ')[1];
    }
    if (!token) return sendError(res, 401, 'Access denied. No token provided.');

    const decoded = verifyAccessToken(token);
    req.userId = decoded.userId;
    req.role = decoded.role;

    if (decoded.role === 'staff') {
      const staff = await Staff.findById(decoded.userId);
      if (!staff || !staff.isActive) return sendError(res, 401, 'Account is inactive or not found.');
      req.user = staff;
    } else if (decoded.role === 'student') {
      const student = await Student.findById(decoded.userId);
      if (!student || !student.isActive) return sendError(res, 401, 'Account is inactive or not found.');
      req.user = student;
    } else {
      console.log("okkk");
      
      return sendError(res, 401, 'Invalid token role.');
    }
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') return sendError(res, 401, 'Token has expired.');
    if (error.name === 'JsonWebTokenError') return sendError(res, 401, 'Invalid token.');
    return sendError(res, 500, 'Authentication failed.');
  }
};

export const staffOnly = (req, res, next) => {
  if (req.role !== 'staff') return sendError(res, 403, 'Access denied. Staff only.');
  next();
};

export const studentOnly = (req, res, next) => {
  if (req.role !== 'student') return sendError(res, 403, 'Access denied. Students only.');
  next();
};
