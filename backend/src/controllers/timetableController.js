import { validationResult } from 'express-validator';
import * as timetableService from '../services/timetableService.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createTimetable = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const entry = await timetableService.create(req.body);
    return sendSuccess(res, 201, 'Timetable entry created successfully', { entry });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getTimetables = async (req, res, next) => {
  try {
    const { entries, pagination } = await timetableService.getAll(req.query);
    return sendPaginated(res, 'Timetable fetched successfully', { entries }, pagination);
  } catch (err) { next(err); }
};

export const getTimetableByBatch = async (req, res, next) => {
  try {
    const entries = await timetableService.getByBatchId(req.params.batchId);
    return sendSuccess(res, 200, 'Timetable fetched successfully', { entries });
  } catch (err) { next(err); }
};

export const getMyTimetable = async (req, res, next) => {
  try {
    if (req.role !== 'student') {
      return sendError(res, 403, 'Access denied. Only students can access this route.');
    }
    const studentService = await import('../services/studentService.js');
    const student = await studentService.getById(req.userId);
    if (!student.batch) {
      return sendSuccess(res, 200, 'My timetable fetched successfully', { entries: [] });
    }
    const entries = await timetableService.getByBatchId(student.batch._id);
    return sendSuccess(res, 200, 'My timetable fetched successfully', { entries });
  } catch (err) { next(err); }
};

export const getTimetable = async (req, res, next) => {
  try {
    const entry = await timetableService.getById(req.params.id);
    return sendSuccess(res, 200, 'Timetable entry fetched successfully', { entry });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateTimetable = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const entry = await timetableService.update(req.params.id, req.body);
    return sendSuccess(res, 200, 'Timetable entry updated successfully', { entry });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteTimetable = async (req, res, next) => {
  try {
    await timetableService.remove(req.params.id);
    return sendSuccess(res, 200, 'Timetable entry deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
