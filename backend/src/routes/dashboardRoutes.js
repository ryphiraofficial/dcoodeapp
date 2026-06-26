import { Router } from 'express';
import { getDashboard } from '../controllers/dashboardController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Dashboard
 *   description: Dashboard analytics
 */

/**
 * @swagger
 * /dashboard:
 *   get:
 *     summary: Get dashboard summary (Staff only)
 *     tags: [Dashboard]
 *     responses:
 *       200:
 *         description: Dashboard data including totals, today's classes, upcoming classes, recent students
 */
router.get('/', protect, staffOnly, getDashboard);

export default router;
