import Certificate from '../models/Certificate.js';
import Student from '../models/Student.js';
import { generateCertificateId } from '../utils/generateId.js';

export const generateCertificate = async (studentId, staffId, description = '') => {
  const student = await Student.findById(studentId).populate('college course batch');
  if (!student) throw { statusCode: 404, message: 'Student not found.' };

  // Check if certificate already exists
  let certificate = await Certificate.findOne({
    student: student._id,
    course: student.course._id,
    batch: student.batch._id,
  });

  if (certificate) {
    throw { statusCode: 409, message: 'Certificate already generated for this student.' };
  }

  const certId = await generateCertificateId();

  certificate = await Certificate.create({
    student: student._id,
    course: student.course._id,
    batch: student.batch._id,
    certificateId: certId,
    description,
    issuedBy: staffId,
  });

  return certificate;
};

export const getCertificateData = async (studentId) => {
  const student = await Student.findById(studentId).populate('college course batch');
  if (!student) throw { statusCode: 404, message: 'Student not found.' };

  const certificate = await Certificate.findOne({
    student: student._id,
    course: student.course._id,
    batch: student.batch._id,
  });

  if (!certificate) throw { statusCode: 404, message: 'Certificate not found for this student.' };

  const formatDate = (date) => {
    if (!date) return '';
    return date.toISOString().split('T')[0];
  };

  return {
    studentName: student.fullName,
    registerNumber: student.registerNumber,
    courseName: student.course?.name || '',
    collegeName: student.college?.name || '',
    batchName: student.batch?.name || '',
    startDate: formatDate(student.batch?.startDate),
    endDate: formatDate(student.batch?.endDate),
    issueDate: formatDate(certificate.issueDate),
    certificateId: certificate.certificateId,
    description: certificate.description || '',
  };
};

// Student: fetch their own certificate
export const getMyCertificate = async (studentId) => {
  const student = await Student.findById(studentId).populate('college course batch');
  if (!student) throw { statusCode: 404, message: 'Student not found.' };

  const certificate = await Certificate.findOne({
    student: student._id,
    course: student.course._id,
    batch: student.batch._id,
  }).populate('issuedBy', 'name');

  if (!certificate) throw { statusCode: 404, message: 'No certificate has been issued for you yet.' };

  const formatDate = (date) => {
    if (!date) return '';
    return date.toISOString().split('T')[0];
  };

  return {
    certificateId: certificate.certificateId,
    description: certificate.description || '',
    studentName: student.fullName,
    registerNumber: student.registerNumber,
    courseName: student.course?.name || '',
    batchName: student.batch?.name || '',
    collegeName: student.college?.name || '',
    startDate: formatDate(student.batch?.startDate),
    endDate: formatDate(student.batch?.endDate),
    issueDate: formatDate(certificate.issueDate),
    issuedBy: certificate.issuedBy?.name || '',
  };
};

export const getCertificatesByBatch = async (batchId) => {
  const certificates = await Certificate.find({ batch: batchId })
    .populate('student', 'fullName registerNumber studentId')
    .populate('course', 'name')
    .populate('issuedBy', 'name');
  return certificates;
};

export const generateBulkCertificates = async (batchId, staffId, description = '') => {
  const students = await Student.find({ batch: batchId }).populate('college course batch');
  if (!students.length) throw { statusCode: 404, message: 'No students found in this batch.' };

  const generated = [];
  const skipped = [];
  const errors = [];

  for (const student of students) {
    try {
      const existing = await Certificate.findOne({
        student: student._id,
        course: student.course._id,
        batch: student.batch._id,
      });

      if (existing) {
        skipped.push({ studentId: student._id, name: student.fullName });
      } else {
        const certId = await generateCertificateId();
        const cert = await Certificate.create({
          student: student._id,
          course: student.course._id,
          batch: student.batch._id,
          certificateId: certId,
          description,
          issuedBy: staffId,
        });
        generated.push({
          studentId: student._id,
          name: student.fullName,
          certificateId: certId,
        });
      }
    } catch (err) {
      errors.push({ studentId: student._id, name: student.fullName, error: err.message });
    }
  }

  return {
    generatedCount: generated.length,
    skippedCount: skipped.length,
    generated,
    skipped,
    errors,
  };
};

export const verifyCertificate = async (certificateId) => {
  const certificate = await Certificate.findOne({ certificateId })
    .populate('student', 'fullName')
    .populate('course', 'name')
    .populate('batch', 'name');

  if (!certificate) {
    return { valid: false };
  }

  const formatDate = (date) => {
    if (!date) return '';
    return date.toISOString().split('T')[0];
  };

  return {
    valid: true,
    studentName: certificate.student.fullName,
    course: certificate.course.name,
    batch: certificate.batch.name,
    issueDate: formatDate(certificate.issueDate),
    certificateId: certificate.certificateId,
    description: certificate.description || '',
  };
};
