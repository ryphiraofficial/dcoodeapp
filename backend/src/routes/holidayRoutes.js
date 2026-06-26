import { Router } from 'express';
import { createHoliday, getHolidays, deleteHoliday } from '../controllers/holidayController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';

const router = Router();

// All routes need authentication
router.use(protect);

/**
 * @swagger
 * tags:
 *   name: Holidays
 *   description: Global and Batch-specific Leaves/Holidays
 */

/**
 * @swagger
 * /holiday:
 *   post:
 *     summary: Mark a leave/holiday for a specific batch or all batches
 *     tags: [Holidays]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [date]
 *             properties:
 *               date: { type: string, format: date, description: "YYYY-MM-DD" }
 *               reason: { type: string, example: "Public Holiday" }
 *               batchId: { type: string, description: "Optional. If not provided, marks leave for all batches." }
 *     responses:
 *       201:
 *         description: Leave marked successfully
 *   get:
 *     summary: Get all holidays/leaves
 *     tags: [Holidays]
 *     parameters:
 *       - in: query
 *         name: batchId
 *         schema: { type: string }
 *         description: If provided, returns holidays for this batch + global holidays
 *       - in: query
 *         name: year
 *         schema: { type: integer }
 *       - in: query
 *         name: month
 *         schema: { type: integer }
 *     responses:
 *       200:
 *         description: List of holidays
 */
router.route('/').post(staffOnly, createHoliday).get(getHolidays);

/**
 * @swagger
 * /holiday/{id}:
 *   delete:
 *     summary: Remove a marked leave/holiday
 *     tags: [Holidays]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Leave removed successfully
 */
router.route('/:id').delete(staffOnly, deleteHoliday);

export default router;
