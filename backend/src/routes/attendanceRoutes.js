import { Router } from 'express';
import { markAttendance, getAttendanceRecords, markLeave, getMyAttendance } from '../controllers/attendanceController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import { bulkAttendanceValidator, markLeaveValidator } from '../validators/attendanceValidator.js';

const router = Router();
router.use(protect);

/**
 * @swagger
 * tags:
 *   name: Attendance
 *   description: Student Attendance Management
 */

/**
 * @swagger
 * /attendance/bulk:
 *   post:
 *     summary: Mark attendance for multiple students in a batch
 *     tags: [Attendance]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [batch, date, records]
 *             properties:
 *               batch: { type: string, description: Batch ObjectId }
 *               date: { type: string, format: date, description: "YYYY-MM-DD" }
 *               records:
 *                 type: array
 *                 items:
 *                   type: object
 *                   required: [student, status]
 *                   properties:
 *                     student: { type: string, description: Student ObjectId }
 *                     status: { type: string, enum: [Present, Absent, Late] }
 *     responses:
 *       201:
 *         description: Attendance marked successfully
 */
router.post('/bulk', staffOnly, bulkAttendanceValidator, markAttendance);

/**
 * @swagger
 * /attendance/leave:
 *   post:
 *     summary: Mark leave for a particular batch or all batches
 *     tags: [Attendance]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [date]
 *             properties:
 *               date: { type: string, format: date, description: "YYYY-MM-DD" }
 *               batchId: { type: string, description: "Optional. Batch ObjectId. If not provided, marks leave for all active students." }
 *     responses:
 *       201:
 *         description: Leave marked successfully
 */
router.post('/leave', staffOnly, markLeaveValidator, markLeave);

/**
 * @swagger
 * /attendance/me:
 *   get:
 *     summary: Get logged in student's attendance records
 *     tags: [Attendance]
 *     responses:
 *       200:
 *         description: My attendance records
 */
router.get('/me', getMyAttendance);

/**
 * @swagger
 * /attendance:
 *   get:
 *     summary: Get attendance records
 *     tags: [Attendance]
 *     parameters:
 *       - in: query
 *         name: batchId
 *         schema: { type: string }
 *       - in: query
 *         name: date
 *         schema: { type: string, format: date }
 *       - in: query
 *         name: studentId
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Attendance records
 */
router.get('/', getAttendanceRecords);

export default router;
