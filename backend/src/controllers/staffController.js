import { validationResult } from 'express-validator';
import * as staffService from '../services/staffService.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createStaff = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const { staff, plainPassword } = await staffService.create(req.body);
    return sendSuccess(res, 201, 'Staff created successfully', { staff, temporaryPassword: plainPassword });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getStaffList = async (req, res, next) => {
  try {
    const { staff, pagination } = await staffService.getAll(req.query);
    return sendPaginated(res, 'Staff fetched successfully', { staff }, pagination);
  } catch (err) { next(err); }
};

export const getStaff = async (req, res, next) => {
  try {
    const staff = await staffService.getById(req.params.id);
    return sendSuccess(res, 200, 'Staff fetched successfully', { staff });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateStaff = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const staff = await staffService.update(req.params.id, req.body);
    return sendSuccess(res, 200, 'Staff updated successfully', { staff });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteStaff = async (req, res, next) => {
  try {
    // Basic protection to prevent staff from deleting themselves if needed
    if (req.userId.toString() === req.params.id) {
      return sendError(res, 400, 'You cannot delete your own account.');
    }

    await staffService.remove(req.params.id);
    return sendSuccess(res, 200, 'Staff deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getMyProfile = async (req, res, next) => {
  try {
    const staff = await staffService.getProfile(req.userId);
    return sendSuccess(res, 200, 'Profile fetched successfully', { staff });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateMyProfile = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    // Prevent staff from changing role or other sensitive fields if any exist
    const { role, ...updateData } = req.body; 

    const staff = await staffService.update(req.userId, updateData);
    return sendSuccess(res, 200, 'Profile updated successfully', { staff });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
