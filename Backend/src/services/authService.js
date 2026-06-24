import Staff from '../models/Staff.js';
import Student from '../models/Student.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../utils/jwtUtils.js';

export const login = async (email, password) => {
  let user = await Staff.findOne({ email }).select('+password +refreshToken');
  let role = 'staff';

  if (!user) {
    user = await Student.findOne({ email }).select('+password +refreshToken');
    role = 'student';
  }
  if (!user) throw { statusCode: 401, message: 'Invalid email or password.' };
  if (!user.isActive) throw { statusCode: 401, message: 'Your account has been deactivated.' };

  const isPasswordValid = await user.comparePassword(password);
  if (!isPasswordValid) throw { statusCode: 401, message: 'Invalid email or password.' };

  const payload = { userId: user._id, role };
  const accessToken = signAccessToken(payload);
  const refreshToken = signRefreshToken(payload);

  user.refreshToken = refreshToken;
  await user.save({ validateBeforeSave: false });

  const userObj = user.toObject();
  delete userObj.password;
  delete userObj.refreshToken;

  return { accessToken, refreshToken, user: userObj, role };
};

export const refresh = async (token) => {
  if (!token) throw { statusCode: 401, message: 'Refresh token not provided.' };

  let decoded;
  try {
    decoded = verifyRefreshToken(token);
  } catch {
    throw { statusCode: 401, message: 'Invalid or expired refresh token.' };
  }

  const Model = decoded.role === 'staff' ? Staff : Student;
  const user = await Model.findById(decoded.userId).select('+refreshToken');
  if (!user || user.refreshToken !== token) {
    throw { statusCode: 401, message: 'Refresh token is invalid or has been revoked.' };
  }

  const payload = { userId: user._id, role: decoded.role };
  const newAccessToken = signAccessToken(payload);
  const newRefreshToken = signRefreshToken(payload);

  user.refreshToken = newRefreshToken;
  await user.save({ validateBeforeSave: false });

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
};

export const logout = async (userId, role) => {
  const Model = role === 'staff' ? Staff : Student;
  await Model.findByIdAndUpdate(userId, { refreshToken: null });
};

export const changePassword = async (userId, role, currentPassword, newPassword) => {
  const Model = role === 'staff' ? Staff : Student;
  const user = await Model.findById(userId).select('+password');
  if (!user) throw { statusCode: 404, message: 'User not found.' };

  const isValid = await user.comparePassword(currentPassword);
  if (!isValid) throw { statusCode: 400, message: 'Current password is incorrect.' };

  user.password = newPassword;
  await user.save();
};
