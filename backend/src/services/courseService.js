import Course from '../models/Course.js';
import College from '../models/College.js';

export const create = async (data) => {
  const college = await College.findById(data.college);
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  const existing = await Course.findOne({ code: data.code.toUpperCase() });
  if (existing) throw { statusCode: 409, message: `Course code '${data.code}' already exists.` };
  const course = await Course.create(data);
  return course.populate('college', 'name code');
};

export const getAll = async (query) => {
  const { page = 1, limit = 20, search, collegeId } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (collegeId) filter.college = collegeId;
  if (search) filter.$or = [
    { name: { $regex: search, $options: 'i' } },
    { code: { $regex: search, $options: 'i' } },
  ];
  const [courses, total] = await Promise.all([
    Course.find(filter).populate('college', 'name code').sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
    Course.countDocuments(filter),
  ]);
  return { courses, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getByCollegeId = async (collegeId) =>
  Course.find({ college: collegeId }).populate('college', 'name code');

export const getById = async (id) => {
  const course = await Course.findById(id).populate('college', 'name code');
  if (!course) throw { statusCode: 404, message: 'Course not found.' };
  return course;
};

export const update = async (id, data) => {
  if (data.code) {
    const existing = await Course.findOne({ code: data.code.toUpperCase(), _id: { $ne: id } });
    if (existing) throw { statusCode: 409, message: `Course code '${data.code}' already exists.` };
  }
  const course = await Course.findByIdAndUpdate(id, data, { new: true, runValidators: true }).populate('college', 'name code');
  if (!course) throw { statusCode: 404, message: 'Course not found.' };
  return course;
};

export const remove = async (id) => {
  const course = await Course.findByIdAndDelete(id);
  if (!course) throw { statusCode: 404, message: 'Course not found.' };
  return course;
};
