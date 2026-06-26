import { validationResult } from 'express-validator';
import * as attendanceService from '../services/attendanceService.js';
import { sendSuccess, sendError } from '../utils/response.js';

export const markAttendance = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const result = await attendanceService.markBulkAttendance(req.userId, req.body);
    return sendSuccess(res, 201, 'Attendance marked successfully', { result });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getAttendanceRecords = async (req, res, next) => {
  try {
    const records = await attendanceService.getAttendance(req.query);
    return sendSuccess(res, 200, 'Attendance fetched successfully', { records });
  } catch (err) {
    next(err);
  }
};

export const getMyAttendance = async (req, res, next) => {
  try {
    if (req.role !== 'student') {
      return sendError(res, 403, 'Access denied. Only students can access this route.');
    }
    const { date } = req.query;
    const query = { studentId: req.userId };
    if (date) query.date = date;

    const records = await attendanceService.getAttendance(query);
    return sendSuccess(res, 200, 'My attendance fetched successfully', { records });
  } catch (err) {
    next(err);
  }
};

export const markLeave = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const result = await attendanceService.markLeave(req.userId, req.body);
    return sendSuccess(res, 201, 'Leave marked successfully', { result });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
