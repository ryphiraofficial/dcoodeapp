import { validationResult } from 'express-validator';
import * as authService from '../services/authService.js';
import { sendSuccess, sendError } from '../utils/response.js';

// Cookie options kept for web/Flutter Web compatibility (optional)
const REFRESH_COOKIE_OPTIONS = {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'strict',
  maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
};

/**
 * POST /api/auth/login
 * Works for Flutter (reads refreshToken from body JSON)
 * and web (sets httpOnly cookie simultaneously)
 */
export const login = async (req, res, next) => {
  try {
    console.log(req.body,"req");
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    }

    const { email, password } = req.body;
    const { accessToken, refreshToken, user, role } = await authService.login(email, password);

    // Set httpOnly cookie for web clients
    res.cookie('refreshToken', refreshToken, REFRESH_COOKIE_OPTIONS);

    // Also return refreshToken in body for Flutter (mobile)
    return sendSuccess(res, 200, 'Login successful', {
      accessToken,
      refreshToken, // Flutter stores this in FlutterSecureStorage
      user,
      role,
    });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

/**
 * POST /api/auth/logout
 */
export const logout = async (req, res, next) => {
  try {
    await authService.logout(req.userId, req.role);
    res.clearCookie('refreshToken');
    return sendSuccess(res, 200, 'Logged out successfully');
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/auth/refresh
 * Flutter sends: { "refreshToken": "..." } in JSON body
 * Web sends: httpOnly cookie (auto-read)
 */
export const refresh = async (req, res, next) => {
  try {
    // Accept token from body (Flutter) OR cookie (web)
    const token = req.body?.refreshToken || req.cookies?.refreshToken;

    const { accessToken, refreshToken } = await authService.refresh(token);

    // Update cookie for web
    res.cookie('refreshToken', refreshToken, REFRESH_COOKIE_OPTIONS);

    // Return both in body for Flutter
    return sendSuccess(res, 200, 'Token refreshed', { accessToken, refreshToken });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

/**
 * POST /api/auth/change-password
 */
export const changePassword = async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return sendError(res, 400, 'Validation failed', errors.array().map((e) => e.msg));
    }

    const { currentPassword, newPassword } = req.body;
    await authService.changePassword(req.userId, req.role, currentPassword, newPassword);
    return sendSuccess(res, 200, 'Password changed successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

/**
 * GET /api/auth/me
 */
export const getMe = async (req, res) => {
  return sendSuccess(res, 200, 'Profile fetched', { user: req.user, role: req.role });
};
