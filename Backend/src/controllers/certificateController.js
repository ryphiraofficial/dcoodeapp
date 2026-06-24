import * as certificateService from '../services/certificateService.js';
import { sendSuccess, sendError } from '../utils/response.js';

export const generate = async (req, res, next) => {
  try {
    const { description = '' } = req.body;
    const certificate = await certificateService.generateCertificate(req.params.studentId, req.userId, description);
    return sendSuccess(res, 201, 'Certificate generated successfully', { certificate });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const generateBulk = async (req, res, next) => {
  try {
    const { description = '' } = req.body;
    const result = await certificateService.generateBulkCertificates(req.params.batchId, req.userId, description);
    return sendSuccess(res, 201, 'Bulk certificate generation completed', result);
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getMyCertificate = async (req, res, next) => {
  try {
    const certificate = await certificateService.getMyCertificate(req.userId);
    return sendSuccess(res, 200, 'Certificate fetched successfully', { certificate });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getCertificate = async (req, res, next) => {
  try {
    // If user is a student, ensure they only request their own certificate
    if (req.role === 'student' && req.userId.toString() !== req.params.studentId) {
      return sendError(res, 403, 'Access denied. You can only view your own certificate.');
    }

    const certificate = await certificateService.getCertificateData(req.params.studentId);

    return res.status(200).json({
      success: true,
      certificate
    });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const getByBatch = async (req, res, next) => {
  try {
    const certificates = await certificateService.getCertificatesByBatch(req.params.batchId);
    return sendSuccess(res, 200, 'Batch certificates fetched successfully', { certificates });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

export const verify = async (req, res, next) => {
  try {
    const data = await certificateService.verifyCertificate(req.params.certificateId);
    if (!data.valid) {
      return res.status(404).json({
        success: false,
        message: 'Invalid Certificate'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Certificate Verified ✅',
      data: {
        studentName: data.studentName,
        course: data.course,
        batch: data.batch,
        issueDate: data.issueDate,
        certificateId: data.certificateId,
        description: data.description,
      }
    });
  } catch (err) {
    next(err);
  }
};
