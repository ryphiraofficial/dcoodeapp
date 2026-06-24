import Student from '../models/Student.js';
import College from '../models/College.js';
import Course from '../models/Course.js';
import Batch from '../models/Batch.js';
import { generateStudentId } from '../utils/generateId.js';
import { generatePassword } from '../utils/generatePassword.js';
import { sendEmail } from '../utils/emailService.js';

const populateFields = [
  { path: 'college', select: 'name code' },
  { path: 'course', select: 'name code durations' },
  { path: 'batch', select: 'name facultyInCharge duration startDate endDate startTime endTime workingDays customWorkingDays' },
];

export const create = async (data) => {
  const [college, course, batch] = await Promise.all([
    College.findById(data.college),
    Course.findById(data.course),
    Batch.findById(data.batch),
  ]);
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  if (!course) throw { statusCode: 404, message: 'Course not found.' };
  if (!batch) throw { statusCode: 404, message: 'Batch not found.' };

  const [existingEmail, existingReg] = await Promise.all([
    Student.findOne({ email: data.email }),
    Student.findOne({ registerNumber: data.registerNumber }),
  ]);
  if (existingEmail) throw { statusCode: 409, message: 'Email already exists.' };
  if (existingReg) throw { statusCode: 409, message: 'Register number already exists.' };

  const studentId = await generateStudentId();
  const plainPassword = generatePassword();

  const student = await Student.create({ ...data, studentId, password: plainPassword });
  const populated = await Student.findById(student._id).populate(populateFields);

  const emailHtml = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <h2 style="color: #2c3e50;">Welcome to Dcoode!</h2>
      <p>Dear ${student.fullName},</p>
      <p>Your student account has been successfully created by the administration.</p>
      <p>You can log in to the student portal using the following credentials:</p>
      <div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
        <p style="margin: 5px 0;"><strong>Email:</strong> ${student.email}</p>
        <p style="margin: 5px 0;"><strong>Password:</strong> ${plainPassword}</p>
      </div>
      <p style="color: #e74c3c; font-size: 0.9em;"><em>Note: Please change your password immediately after logging in.</em></p>
      <br>
      <p>Best Regards,<br><strong>Dcoode Administration</strong></p>
    </div>
  `;

  await sendEmail({
    to: student.email,
    subject: 'Welcome to Dcoode - Your Account Credentials',
    html: emailHtml,
  });

  return { student: populated, plainPassword };
};

export const getAll = async (query) => {
  const { page = 1, limit = 20, search, collegeId, courseId, batchId } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (collegeId) filter.college = collegeId;
  if (courseId) filter.course = courseId;
  if (batchId) filter.batch = batchId;
  if (search) {
    filter.$or = [
      { fullName: { $regex: search, $options: 'i' } },
      { studentId: { $regex: search, $options: 'i' } },
      { registerNumber: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
    ];
  }

  const [students, total] = await Promise.all([
    Student.find(filter).populate(populateFields).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
    Student.countDocuments(filter),
  ]);
  return { students, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getById = async (id) => {
  const student = await Student.findById(id).populate(populateFields);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };
  return student;
};

export const update = async (id, data, isStaff = true) => {
  // Students cannot modify college/course/batch/studentId
  if (!isStaff) {
    delete data.college;
    delete data.course;
    delete data.batch;
    delete data.studentId;
    delete data.registerNumber;
    delete data.rollNumber;
  }

  const student = await Student.findByIdAndUpdate(id, data, { new: true, runValidators: true }).populate(populateFields);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };
  return student;
};

export const remove = async (id) => {
  const student = await Student.findByIdAndDelete(id);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };
  return student;
};

export const getProfile = async (id) => {
  const student = await Student.findById(id).populate(populateFields);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };
  return student;
};

export const addCertification = async (studentId, certData) => {
  const student = await Student.findByIdAndUpdate(
    studentId,
    { $push: { certifications: certData } },
    { new: true }
  ).populate(populateFields);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };
  return student;
};

export const removeCertification = async (studentId, certId) => {
  const student = await Student.findById(studentId);
  if (!student) throw { statusCode: 404, message: 'Student not found.' };

  const cert = student.certifications.id(certId);
  if (!cert) throw { statusCode: 404, message: 'Certification not found.' };

  const deletedKey = cert.key;
  student.certifications.pull({ _id: certId });
  await student.save();

  const populated = await Student.findById(studentId).populate(populateFields);
  return { student: populated, deletedKey };
};

