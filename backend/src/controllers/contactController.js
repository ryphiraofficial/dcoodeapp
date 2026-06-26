import * as contactService from '../services/contactService.js';
import { sendSuccess, sendError, sendPaginated } from '../utils/response.js';

// POST /api/contact  — Public
export const send = async (req, res, next) => {
  try {
    const { name, email, message } = req.body;
    const contact = await contactService.sendContactMessage(name, email, message);
    return sendSuccess(res, 201, 'Message sent successfully. We will get back to you soon!', { contact });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

// GET /api/contact  — Staff only
export const getAll = async (req, res, next) => {
  try {
    const unreadOnly = req.query.unread === 'true';
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;

    const { messages, pagination } = await contactService.getAllMessages({ unreadOnly, page, limit });
    return sendPaginated(res, 'Messages fetched successfully', messages, pagination);
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

// GET /api/contact/unread-count  — Staff only
export const unreadCount = async (req, res, next) => {
  try {
    const data = await contactService.getUnreadCount();
    return sendSuccess(res, 200, 'Unread count fetched', data);
  } catch (err) {
    next(err);
  }
};

// PATCH /api/contact/:id/read  — Staff only
export const markRead = async (req, res, next) => {
  try {
    const msg = await contactService.markAsRead(req.params.id);
    return sendSuccess(res, 200, 'Message marked as read', { message: msg });
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};

// PATCH /api/contact/read-all  — Staff only
export const markAllRead = async (req, res, next) => {
  try {
    await contactService.markAllAsRead();
    return sendSuccess(res, 200, 'All messages marked as read');
  } catch (err) {
    next(err);
  }
};

// DELETE /api/contact/:id  — Staff only
export const remove = async (req, res, next) => {
  try {
    await contactService.deleteMessage(req.params.id);
    return sendSuccess(res, 200, 'Message deleted successfully');
  } catch (err) {
    if (err.statusCode) return sendError(res, err.statusCode, err.message);
    next(err);
  }
};
