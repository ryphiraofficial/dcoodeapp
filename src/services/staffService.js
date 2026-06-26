import Staff from '../models/Staff.js';
import { generatePassword } from '../utils/generatePassword.js';

export const create = async (data) => {
  const existingEmail = await Staff.findOne({ email: data.email });
  if (existingEmail) throw { statusCode: 409, message: 'Email already exists.' };

  const plainPassword = data.password || generatePassword();

  const staff = await Staff.create({ ...data, password: plainPassword });
  
  return { staff, plainPassword };
};

export const getAll = async (query) => {
  const { page = 1, limit = 20, search } = query;
  const skip = (page - 1) * limit;
  const filter = {};
  if (search) {
    filter.$or = [
      { name: { $regex: search, $options: 'i' } },
      { email: { $regex: search, $options: 'i' } },
    ];
  }

  const [staffList, total] = await Promise.all([
    Staff.find(filter).sort({ createdAt: -1 }).skip(skip).limit(parseInt(limit)),
    Staff.countDocuments(filter),
  ]);
  return { staff: staffList, pagination: { total, page: parseInt(page), limit: parseInt(limit), totalPages: Math.ceil(total / limit) } };
};

export const getById = async (id) => {
  const staff = await Staff.findById(id);
  if (!staff) throw { statusCode: 404, message: 'Staff not found.' };
  return staff;
};

export const update = async (id, data) => {
  const staff = await Staff.findByIdAndUpdate(id, data, { new: true, runValidators: true });
  if (!staff) throw { statusCode: 404, message: 'Staff not found.' };
  return staff;
};

export const remove = async (id) => {
  const staff = await Staff.findByIdAndDelete(id);
  if (!staff) throw { statusCode: 404, message: 'Staff not found.' };
  return staff;
};

export const getProfile = async (id) => {
  const staff = await Staff.findById(id);
  if (!staff) throw { statusCode: 404, message: 'Staff not found.' };
  return staff;
};
