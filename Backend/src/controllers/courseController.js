import { validationResult } from 'express-validator';
import * as courseService from '../services/courseService.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createCourse = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const course = await courseService.create(req.body);
    return sendSuccess(res, 201, 'Course created successfully', { course });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getCourses = async (req, res, next) => {
  try {
    const { courses, pagination } = await courseService.getAll(req.query);
    return sendPaginated(res, 'Courses fetched successfully', { courses }, pagination);
  } catch (err) { next(err); }
};

export const getCoursesByCollege = async (req, res, next) => {
  try {
    const courses = await courseService.getByCollegeId(req.params.collegeId);
    return sendSuccess(res, 200, 'Courses fetched successfully', { courses });
  } catch (err) { next(err); }
};

export const getCourse = async (req, res, next) => {
  try {
    const course = await courseService.getById(req.params.id);
    return sendSuccess(res, 200, 'Course fetched successfully', { course });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateCourse = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const course = await courseService.update(req.params.id, req.body);
    return sendSuccess(res, 200, 'Course updated successfully', { course });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteCourse = async (req, res, next) => {
  try {
    await courseService.remove(req.params.id);
    return sendSuccess(res, 200, 'Course deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
