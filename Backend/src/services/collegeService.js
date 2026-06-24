import College from '../models/College.js';

export const create = async (data, staffId) => {
  const existing = await College.findOne({ code: data.code.toUpperCase() });
  if (existing) throw { statusCode: 409, message: `College code '${data.code}' already exists.` };
  return await College.create({ ...data, createdBy: staffId });
};

export const getAll = async (query) => {
  const { page = 1, limit = 20, search, status } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (status) filter.status = status;
  if (search) filter.$or = [
    { name: { $regex: search, $options: 'i' } },
    { code: { $regex: search, $options: 'i' } },
    { principalName: { $regex: search, $options: 'i' } },
  ];

  const [colleges, total] = await Promise.all([
    College.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
    College.countDocuments(filter),
  ]);
  return { colleges, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getById = async (id) => {
  const college = await College.findById(id);
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  return college;
};

export const update = async (id, data) => {
  if (data.code) {
    const existing = await College.findOne({ code: data.code.toUpperCase(), _id: { $ne: id } });
    if (existing) throw { statusCode: 409, message: `College code '${data.code}' already exists.` };
  }
  const college = await College.findByIdAndUpdate(id, data, { new: true, runValidators: true });
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  return college;
};

export const remove = async (id) => {
  const college = await College.findByIdAndDelete(id);
  if (!college) throw { statusCode: 404, message: 'College not found.' };
  return college;
};
