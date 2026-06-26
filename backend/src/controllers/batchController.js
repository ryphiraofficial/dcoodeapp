import { validationResult } from 'express-validator';
import * as batchService from '../services/batchService.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createBatch = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const batch = await batchService.create(req.body);
    return sendSuccess(res, 201, 'Batch created successfully', { batch });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getBatches = async (req, res, next) => {
  try {
    const { batches, pagination } = await batchService.getAll(req.query);
    return sendPaginated(res, 'Batches fetched successfully', { batches }, pagination);
  } catch (err) { next(err); }
};

export const getBatchesByCourse = async (req, res, next) => {
  try {
    const batches = await batchService.getByCourseId(req.params.courseId);
    return sendSuccess(res, 200, 'Batches fetched successfully', { batches });
  } catch (err) { next(err); }
};

export const getBatch = async (req, res, next) => {
  try {
    const batch = await batchService.getById(req.params.id);
    return sendSuccess(res, 200, 'Batch fetched successfully', { batch });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateBatch = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    const batch = await batchService.update(req.params.id, req.body);
    return sendSuccess(res, 200, 'Batch updated successfully', { batch });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteBatch = async (req, res, next) => {
  try {
    await batchService.remove(req.params.id);
    return sendSuccess(res, 200, 'Batch deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
