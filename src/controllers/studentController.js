import { validationResult } from 'express-validator';
import * as studentService from '../services/studentService.js';
import { uploadToR2, deleteFromR2 } from '../utils/r2Upload.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

export const createStudent = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    const data = { ...req.body };

    if (req.file) {
      const { key, url } = await uploadToR2(req.file.buffer, req.file.originalname, 'photos');
      data.photo = url;
      data.photoKey = key;
    }

    const { student, plainPassword } = await studentService.create(data);
    return sendSuccess(res, 201, 'Student created successfully', { student, temporaryPassword: plainPassword });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getStudents = async (req, res, next) => {
  try {
    const { students, pagination } = await studentService.getAll(req.query);
    return sendPaginated(res, 'Students fetched successfully', { students }, pagination);
  } catch (err) { next(err); }
};

export const getStudent = async (req, res, next) => {
  try {
    if (req.role === 'student' && req.userId.toString() !== req.params.id) {
      return sendError(res, 403, 'Access denied. You can only view your own profile.');
    }
    const student = await studentService.getById(req.params.id);
    return sendSuccess(res, 200, 'Student fetched successfully', { student });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const updateStudent = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));

    if (req.role === 'student' && req.userId.toString() !== req.params.id) {
      return sendError(res, 403, 'Access denied. You can only edit your own profile.');
    }

    const data = { ...req.body };

    if (req.file) {
      // Delete old photo from R2
      const existing = await studentService.getById(req.params.id);
      if (existing.photoKey) await deleteFromR2(existing.photoKey);

      const { key, url } = await uploadToR2(req.file.buffer, req.file.originalname, 'photos');
      data.photo = url;
      data.photoKey = key;
    }

    const isStaff = req.role === 'staff';
    const student = await studentService.update(req.params.id, data, isStaff);
    return sendSuccess(res, 200, 'Student updated successfully', { student });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteStudent = async (req, res, next) => {
  try {
    const student = await studentService.getById(req.params.id);
    // Delete photo from R2
    if (student.photoKey) await deleteFromR2(student.photoKey);
    // Delete all certifications from R2
    for (const cert of student.certifications || []) {
      if (cert.key) await deleteFromR2(cert.key);
    }

    await studentService.remove(req.params.id);
    return sendSuccess(res, 200, 'Student deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getMyProfile = async (req, res, next) => {
  try {
    const student = await studentService.getProfile(req.userId);
    return sendSuccess(res, 200, 'Profile fetched successfully', { student });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

// ─── Certifications ────────────────────────────────────────────────────────────

export const uploadCertification = async (req, res, next) => {
  try {
    if (!req.file) return sendError(res, 400, 'No file uploaded.');

    const { name } = req.body;
    if (!name) return sendError(res, 400, 'Certification name is required.');

    // Students can only upload to their own profile
    if (req.role === 'student' && req.userId.toString() !== req.params.id) {
      return sendError(res, 403, 'Access denied.');
    }

    const { key, url } = await uploadToR2(req.file.buffer, req.file.originalname, 'certifications');
    const student = await studentService.addCertification(req.params.id, { name, url, key });
    return sendSuccess(res, 201, 'Certification uploaded successfully', { student });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const deleteCertification = async (req, res, next) => {
  try {
    if (req.role === 'student' && req.userId.toString() !== req.params.id) {
      return sendError(res, 403, 'Access denied.');
    }

    const { student, deletedKey } = await studentService.removeCertification(
      req.params.id,
      req.params.certId
    );

    if (deletedKey) await deleteFromR2(deletedKey);
    return sendSuccess(res, 200, 'Certification deleted successfully', { student });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
