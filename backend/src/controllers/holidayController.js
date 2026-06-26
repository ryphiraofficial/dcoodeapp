import Holiday from '../models/Holiday.js';
import { sendSuccess, sendError } from '../utils/response.js';

export const createHoliday = async (req, res, next) => {
  try {
    const { date, reason, batchId } = req.body;
    
    if (!date) {
      return sendError(res, 400, 'Date is required');
    }

    const holidayDate = new Date(date);
    holidayDate.setUTCHours(0, 0, 0, 0);

    const holiday = await Holiday.findOneAndUpdate(
      { date: holidayDate, batch: batchId || null },
      { reason: reason || 'Leave', markedBy: req.userId },
      { new: true, upsert: true }
    );

    return sendSuccess(res, 201, 'Leave marked successfully', { holiday });
  } catch (err) {
    next(err);
  }
};

export const getHolidays = async (req, res, next) => {
  try {
    const { batchId, year, month } = req.query;
    const filter = {};

    if (batchId) {
      // Find holidays for this specific batch, AND global holidays (batch: null)
      filter.$or = [{ batch: batchId }, { batch: null }];
    } else {
      // If no batchId provided, just get global holidays or all holidays
      // Usually staff wants all holidays, or global ones. We'll return all.
    }

    if (year && month) {
      const startDate = new Date(Date.UTC(year, month - 1, 1));
      const endDate = new Date(Date.UTC(year, month, 0, 23, 59, 59));
      filter.date = { $gte: startDate, $lte: endDate };
    }

    const holidays = await Holiday.find(filter).populate('batch', 'name').sort({ date: 1 });
    return sendSuccess(res, 200, 'Holidays fetched successfully', { holidays });
  } catch (err) {
    next(err);
  }
};

export const deleteHoliday = async (req, res, next) => {
  try {
    const holiday = await Holiday.findByIdAndDelete(req.params.id);
    if (!holiday) return sendError(res, 404, 'Holiday/Leave not found');
    return sendSuccess(res, 200, 'Leave removed successfully');
  } catch (err) {
    next(err);
  }
};
