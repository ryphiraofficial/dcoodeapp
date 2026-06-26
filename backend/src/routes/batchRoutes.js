import { Router } from 'express';
import { createBatch, getBatches, getBatchesByCourse, getBatch, updateBatch, deleteBatch } from '../controllers/batchController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import { createBatchValidator, updateBatchValidator } from '../validators/batchValidator.js';

const router = Router();
router.use(protect, staffOnly);

/**
 * @swagger
 * tags:
 *   name: Batches
 *   description: Batch management
 */

/**
 * @swagger
 * /batch:
 *   post:
 *     summary: Create a new batch
 *     tags: [Batches]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, college, course, duration, startDate]
 *             properties:
 *               name: { type: string }
 *               facultyInCharge: { type: string }
 *               college: { type: string, description: College ObjectId }
 *               course: { type: string, description: Course ObjectId }
 *               duration: { type: string }
 *               startDate: { type: string, format: date }
 *               endDate: { type: string, format: date }
 *               startTime: { type: string, description: "Start time of the batch, e.g., '09:00 AM'" }
 *               endTime: { type: string, description: "End time of the batch, e.g., '11:00 AM'" }
 *               workingDays: { type: string, enum: ['Monday-Friday', 'Weekend', 'Custom'] }
 *               customWorkingDays: { type: array, items: { type: string } }
 *     responses:
 *       201:
 *         description: Batch created
 *   get:
 *     summary: Get all batches
 *     tags: [Batches]
 *     parameters:
 *       - in: query
 *         name: collegeId
 *         schema: { type: string }
 *       - in: query
 *         name: courseId
 *         schema: { type: string }
 *       - in: query
 *         name: faculty
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of batches
 */
router.route('/').post(createBatchValidator, createBatch).get(getBatches);

/**
 * @swagger
 * /batch/{courseId}:
 *   get:
 *     summary: Get batches by course ID
 *     tags: [Batches]
 *     parameters:
 *       - in: path
 *         name: courseId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Batches for the course
 */
router.get('/:courseId', getBatchesByCourse);

/**
 * @swagger
 * /batch/{id}:
 *   put:
 *     summary: Update batch
 *     tags: [Batches]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Batch updated
 *   delete:
 *     summary: Delete batch
 *     tags: [Batches]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Batch deleted
 */
router.route('/:id').put(updateBatchValidator, updateBatch).delete(deleteBatch);

export default router;
