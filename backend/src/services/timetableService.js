import Timetable from '../models/Timetable.js';
import Batch from '../models/Batch.js';

const populate = [{ path: 'batch', select: 'name', populate: [{ path: 'college', select: 'name' }, { path: 'course', select: 'name' }] }];

export const create = async (data) => {
  const batch = await Batch.findById(data.batch);
  if (!batch) throw { statusCode: 404, message: 'Batch not found.' };
  const entry = await Timetable.create(data);
  return entry.populate(populate);
};

export const getAll = async (query) => {
  const { page = 1, limit = 50, batchId, date, faculty } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (batchId) filter.batch = batchId;
  if (faculty) filter.faculty = { $regex: faculty, $options: 'i' };
  if (date) {
    const start = new Date(date);
    start.setHours(0, 0, 0, 0);
    const end = new Date(date);
    end.setHours(23, 59, 59, 999);
    filter.date = { $gte: start, $lte: end };
  }

  const [entries, total] = await Promise.all([
    Timetable.find(filter).populate(populate).sort({ date: 1, startTime: 1 }).skip(skip).limit(parseInt(limit)),
    Timetable.countDocuments(filter),
  ]);
  return { entries, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getByBatchId = async (batchId) =>
  Timetable.find({ batch: batchId }).populate(populate).sort({ date: 1, startTime: 1 });

export const getById = async (id) => {
  const entry = await Timetable.findById(id).populate(populate);
  if (!entry) throw { statusCode: 404, message: 'Timetable entry not found.' };
  return entry;
};

export const update = async (id, data) => {
  const entry = await Timetable.findByIdAndUpdate(id, data, { new: true, runValidators: true }).populate(populate);
  if (!entry) throw { statusCode: 404, message: 'Timetable entry not found.' };
  return entry;
};

export const remove = async (id) => {
  const entry = await Timetable.findByIdAndDelete(id);
  if (!entry) throw { statusCode: 404, message: 'Timetable entry not found.' };
  return entry;
};

export const getTodayClasses = async () => {
  const start = new Date();
  start.setHours(0, 0, 0, 0);
  const end = new Date();
  end.setHours(23, 59, 59, 999);
  return Timetable.find({ date: { $gte: start, $lte: end } }).populate(populate).sort({ startTime: 1 });
};

export const getUpcomingClasses = async (limit = 10) => {
  const now = new Date();
  return Timetable.find({ date: { $gt: now } }).populate(populate).sort({ date: 1, startTime: 1 }).limit(limit);
};
