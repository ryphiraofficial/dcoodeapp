import College from '../models/College.js';
import Course from '../models/Course.js';
import Batch from '../models/Batch.js';
import Student from '../models/Student.js';
import Timetable from '../models/Timetable.js';

export const getDashboard = async () => {
  const now = new Date();
  const todayStart = new Date(now);
  todayStart.setHours(0, 0, 0, 0);
  const todayEnd = new Date(now);
  todayEnd.setHours(23, 59, 59, 999);

  const [
    totalColleges,
    totalCourses,
    totalBatches,
    totalStudents,
    todaysClasses,
    upcomingClasses,
    recentStudents,
  ] = await Promise.all([
    College.countDocuments({ status: 'active' }),
    Course.countDocuments({ isActive: true }),
    Batch.countDocuments({ isActive: true }),
    Student.countDocuments({ isActive: true }),
    Timetable.find({ date: { $gte: todayStart, $lte: todayEnd } })
      .populate({ path: 'batch', select: 'name', populate: { path: 'course', select: 'name' } })
      .sort({ startTime: 1 })
      .limit(20),
    Timetable.find({ date: { $gt: todayEnd } })
      .populate({ path: 'batch', select: 'name', populate: { path: 'course', select: 'name' } })
      .sort({ date: 1, startTime: 1 })
      .limit(10),
    Student.find({ isActive: true })
      .populate('college', 'name')
      .populate('course', 'name')
      .populate('batch', 'name')
      .sort({ createdAt: -1 })
      .limit(5),
  ]);

  return {
    summary: { totalColleges, totalCourses, totalBatches, totalStudents },
    todaysClasses,
    upcomingClasses,
    recentStudents,
  };
};
