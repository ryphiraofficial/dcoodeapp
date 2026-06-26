import ContactMessage from '../models/ContactMessage.js';

// Public: Save a contact message from the app's Contact page
export const sendContactMessage = async (name, email, message) => {
  if (!name || !name.trim()) throw { statusCode: 400, message: 'Name is required.' };
  if (!email || !email.trim()) throw { statusCode: 400, message: 'Email is required.' };
  if (!message || !message.trim()) throw { statusCode: 400, message: 'Message is required.' };

  const contact = await ContactMessage.create({
    name: name.trim(),
    email: email.trim().toLowerCase(),
    message: message.trim(),
  });

  return contact;
};

// Staff: Get all contact messages (newest first), with optional unread filter
export const getAllMessages = async ({ unreadOnly = false, page = 1, limit = 20 } = {}) => {
  const filter = unreadOnly ? { isRead: false } : {};
  const skip = (page - 1) * limit;

  const [messages, total] = await Promise.all([
    ContactMessage.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    ContactMessage.countDocuments(filter),
  ]);

  return {
    messages,
    pagination: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
};

// Staff: Get unread message count (for badge)
export const getUnreadCount = async () => {
  const count = await ContactMessage.countDocuments({ isRead: false });
  return { unreadCount: count };
};

// Staff: Mark a single message as read
export const markAsRead = async (messageId) => {
  const msg = await ContactMessage.findByIdAndUpdate(
    messageId,
    { isRead: true },
    { new: true }
  );
  if (!msg) throw { statusCode: 404, message: 'Message not found.' };
  return msg;
};

// Staff: Mark ALL messages as read
export const markAllAsRead = async () => {
  await ContactMessage.updateMany({ isRead: false }, { isRead: true });
  return { success: true };
};

// Staff: Delete a message
export const deleteMessage = async (messageId) => {
  const msg = await ContactMessage.findByIdAndDelete(messageId);
  if (!msg) throw { statusCode: 404, message: 'Message not found.' };
  return { deleted: true };
};
