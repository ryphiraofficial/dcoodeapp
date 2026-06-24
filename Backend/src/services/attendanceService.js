import Attendance from '../models/Attendance.js';
import Batch from '../models/Batch.js';
import Student from '../models/Student.js';

export const markBulkAttendance = async (staffId, data) => {
  const { batch, date, records, task, description, files } = data;

  const batchExists = await Batch.findById(batch);
  if (!batchExists) {
    throw { statusCode: 404, message: 'Batch not found' };
  }

  // Normalize date to midnight UTC to avoid timezone issues
  const attendanceDate = new Date(date);
  attendanceDate.setUTCHours(0, 0, 0, 0);

  const operations = records.map((record) => {
    const setObj = {
      status: record.status,
      markedBy: staffId,
    };
    if (task !== undefined) setObj.task = task;
    if (description !== undefined) setObj.description = description;
    if (files !== undefined) setObj.files = files;

    return {
      updateOne: {
        filter: { student: record.student, batch, date: attendanceDate },
        update: { $set: setObj },
        upsert: true,
      },
    };
  });

  const result = await Attendance.bulkWrite(operations);
  return result;
};

export const getAttendance = async (query) => {
  const { batchId, date, studentId } = query;
  const filter = {};

  if (batchId) filter.batch = batchId;
  if (studentId) filter.student = studentId;
  if (date) {
    const attendanceDate = new Date(date);
    attendanceDate.setUTCHours(0, 0, 0, 0);
    filter.date = attendanceDate;
  }

  const attendanceRecords = await Attendance.find(filter)
    .populate('student', 'fullName registerNumber rollNumber studentId')
    .populate('markedBy', 'name');

  return attendanceRecords;
};

export const markLeave = async (staffId, data) => {
  const { date, batchId } = data;

  const attendanceDate = new Date(date);
  attendanceDate.setUTCHours(0, 0, 0, 0);

  const filter = { isActive: true };
  if (batchId) {
    const batchExists = await Batch.findById(batchId);
    if (!batchExists) throw { statusCode: 404, message: 'Batch not found' };
    filter.batch = batchId;
  }

  const students = await Student.find(filter).select('_id batch');
  
  if (students.length === 0) {
    throw { statusCode: 404, message: 'No active students found for the given criteria' };
  }

  const operations = students.map((student) => ({
    updateOne: {
      filter: { student: student._id, batch: student.batch, date: attendanceDate },
      update: {
        $set: {
          status: 'Leave',
          markedBy: staffId,
        },
      },
      upsert: true,
    },
  }));

  const result = await Attendance.bulkWrite(operations);
  return result;
};
