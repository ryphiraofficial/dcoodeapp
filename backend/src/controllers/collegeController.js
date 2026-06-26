import { validationResult } from 'express-validator';
import * as collegeService from '../services/collegeService.js';
import { uploadToR2, deleteFromR2, extractR2Key } from '../utils/r2Upload.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createCollege = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const data = { ...req.body };

    if (req.file) {
      const { key, url } = await uploadToR2(req.file.buffer, req.file.originalname, 'logos');
      data.logo = url;
      data.logoKey = key;
    }

    const college = await collegeService.create(data, req.userId);
    return sendSuccess(res, 201, 'College created successfully', { college });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getColleges = async (req, res, next) => {
  try {
    const { colleges, pagination } = await collegeService.getAll(req.query);
    return sendPaginated(res, 'Colleges fetched successfully', { colleges }, pagination);
  } catch (err) { next(err); }
};

export const getCollege = async (req, res, next) => {
  try {
    const college = await collegeService.getById(req.params.id);
    return sendSuccess(res, 200, 'College fetched successfully', { college });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateCollege = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const data = { ...req.body };

    if (req.file) {
      // Delete old logo from R2 if it exists
      const existing = await collegeService.getById(req.params.id);
      if (existing.logoKey) await deleteFromR2(existing.logoKey);

      const { key, url } = await uploadToR2(req.file.buffer, req.file.originalname, 'logos');
      data.logo = url;
      data.logoKey = key;
    }

    const college = await collegeService.update(req.params.id, data);
    return sendSuccess(res, 200, 'College updated successfully', { college });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteCollege = async (req, res, next) => {
  try {
    const college = await collegeService.getById(req.params.id);
    if (college.logoKey) await deleteFromR2(college.logoKey);

    await collegeService.remove(req.params.id);
    return sendSuccess(res, 200, 'College deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
