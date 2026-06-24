import { Router } from 'express';
import {
  createTimetable, getTimetables, getTimetableByBatch,
  getTimetable, updateTimetable, deleteTimetable, getMyTimetable
} from '../controllers/timetableController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import { createTimetableValidator, updateTimetableValidator } from '../validators/timetableValidator.js';

const router = Router();
router.use(protect);

/**
 * @swagger
 * tags:
 *   name: Timetable
 *   description: Timetable management
 */

/**
 * @swagger
 * /timetable:
 *   post:
 *     summary: Create a timetable entry
 *     tags: [Timetable]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [batch, subject, faculty, date, startTime, endTime]
 *             properties:
 *               batch: { type: string }
 *               subject: { type: string }
 *               faculty: { type: string }
 *               date: { type: string, format: date, example: 2026-06-15 }
 *               startTime: { type: string, example: "09:00" }
 *               endTime: { type: string, example: "10:30" }
 *               classroom: { type: string }
 *     responses:
 *       201:
 *         description: Timetable entry created
 *   get:
 *     summary: Get all timetable entries
 *     tags: [Timetable]
 *     parameters:
 *       - in: query
 *         name: batchId
 *         schema: { type: string }
 *       - in: query
 *         name: date
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: faculty
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Timetable entries
 */
router.route('/').post(staffOnly, createTimetableValidator, createTimetable).get(staffOnly, getTimetables);

/**
 * @swagger
 * /timetable/me:
 *   get:
 *     summary: Get logged in student's timetable
 *     tags: [Timetable]
 *     responses:
 *       200:
 *         description: My timetable
 */
router.get('/me', getMyTimetable);

/**
 * @swagger
 * /timetable/{batchId}:
 *   get:
 *     summary: Get timetable by batch ID
 *     tags: [Timetable]
 *     parameters:
 *       - in: path
 *         name: batchId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Timetable for the batch
 */
router.get('/:batchId', getTimetableByBatch);

/**
 * @swagger
 * /timetable/{id}:
 *   put:
 *     summary: Update timetable entry
 *     tags: [Timetable]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Entry updated
 *   delete:
 *     summary: Delete timetable entry
 *     tags: [Timetable]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Entry deleted
 */
router.route('/:id').put(staffOnly, updateTimetableValidator, updateTimetable).delete(staffOnly, deleteTimetable);

export default router;
