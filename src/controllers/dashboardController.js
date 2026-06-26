import * as dashboardService from '../services/dashboardService.js';
import { sendSuccess } from '../utils/response.js';

export const getDashboard = async (req, res, next) => {
  try {
    const data = await dashboardService.getDashboard();
    return sendSuccess(res, 200, 'Dashboard data fetched successfully', data);
  } catch (err) { next(err); }
};
