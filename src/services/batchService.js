import Batch from '../models/Batch.js';
import Course from '../models/Course.js';
import College from '../models/College.js';

const populate = [{ path: 'college', select: 'name code' }, { path: 'course', select: 'name code' }];

export const create = async (data) => {
  const [college, course] = await Promise.all([College.findById(data.college), Course.findById(data.course)]);
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  if (!course) throw { statusCode: 404, message: 'Course not found.' };
  const batch = await Batch.create(data);
  return batch.populate(populate);
};

export const getAll = async (query) => {
  const { page = 1, limit = 20, search, collegeId, courseId, faculty } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (collegeId) filter.college = collegeId;
  if (courseId) filter.course = courseId;
  if (faculty) filter.facultyInCharge = { $regex: faculty, $options: 'i' };
  if (search) filter.name = { $regex: search, $options: 'i' };

  const [batches, total] = await Promise.all([
    Batch.find(filter).populate(populate).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
    Batch.countDocuments(filter),
  ]);
  return { batches, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getByCourseId = async (courseId) => Batch.find({ course: courseId }).populate(populate);

export const getById = async (id) => {
  const batch = await Batch.findById(id).populate(populate);
  if (!batch) throw { statusCode: 404, message: 'Batch not found.' };
  return batch;
};

export const update = async (id, data) => {
  const batch = await Batch.findByIdAndUpdate(id, data, { new: true, runValidators: true }).populate(populate);
  if (!batch) throw { statusCode: 404, message: 'Batch not found.' };
  return batch;
};

export const remove = async (id) => {
  const batch = await Batch.findByIdAndDelete(id);
  if (!batch) throw { statusCode: 404, message: 'Batch not found.' };
  return batch;
};
