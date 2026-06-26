import { Router } from 'express';
import { send, getAll, unreadCount, markRead, markAllRead, remove } from '../controllers/contactController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Contact
 *   description: Contact / Enquiry Messages
 */

/**
 * @swagger
 * /contact:
 *   post:
 *     summary: Send a contact message (Public — no auth required)
 *     tags: [Contact]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, message]
 *             properties:
 *               name:
 *                 type: string
 *                 example: "John Doe"
 *               email:
 *                 type: string
 *                 example: "john@example.com"
 *               message:
 *                 type: string
 *                 example: "I would like to know more about your courses."
 *     responses:
 *       201:
 *         description: Message sent successfully
 *       400:
 *         description: Validation error
 */
router.post('/', send);

// All routes below require authentication and staff role
router.use(protect, staffOnly);

/**
 * @swagger
 * /contact/unread-count:
 *   get:
 *     summary: Get count of unread messages (Staff only)
 *     tags: [Contact]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Returns unreadCount number
 */
router.get('/unread-count', unreadCount);

/**
 * @swagger
 * /contact/read-all:
 *   patch:
 *     summary: Mark all messages as read (Staff only)
 *     tags: [Contact]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All messages marked as read
 */
router.patch('/read-all', markAllRead);

/**
 * @swagger
 * /contact:
 *   get:
 *     summary: Get all contact messages (Staff only)
 *     tags: [Contact]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: unread
 *         schema: { type: boolean }
 *         description: Set to true to fetch only unread messages
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *     responses:
 *       200:
 *         description: Paginated list of contact messages
 */
router.get('/', getAll);

/**
 * @swagger
 * /contact/{id}/read:
 *   patch:
 *     summary: Mark a single message as read (Staff only)
 *     tags: [Contact]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Message marked as read
 *       404:
 *         description: Message not found
 */
router.patch('/:id/read', markRead);

/**
 * @swagger
 * /contact/{id}:
 *   delete:
 *     summary: Delete a contact message (Staff only)
 *     tags: [Contact]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Message deleted
 *       404:
 *         description: Message not found
 */
router.delete('/:id', remove);

export default router;
