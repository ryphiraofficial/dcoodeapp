import { Router } from 'express';
import { createCollege, getColleges, getCollege, updateCollege, deleteCollege } from '../controllers/collegeController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import upload from '../middleware/uploadMiddleware.js';
import { createCollegeValidator, updateCollegeValidator } from '../validators/collegeValidator.js';

const router = Router();
router.use(protect, staffOnly);

/**
 * @swagger
 * tags:
 *   name: Colleges
 *   description: College management
 */

/**
 * @swagger
 * /college:
 *   post:
 *     summary: Create a new college
 *     tags: [Colleges]
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [name, code]
 *             properties:
 *               name: { type: string }
 *               code: { type: string }
 *               address: { type: string }
 *               email: { type: string }
 *               phone: { type: string }
 *               principalName: { type: string }
 *               status: { type: string, enum: [active, inactive] }
 *               logo: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: College created
 *   get:
 *     summary: Get all colleges (with pagination & search)
 *     tags: [Colleges]
 *     parameters:
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *       - in: query
 *         name: status
 *         schema: { type: string, enum: [active, inactive] }
 *       - in: query
 *         name: page
 *         schema: { type: integer, default: 1 }
 *       - in: query
 *         name: limit
 *         schema: { type: integer, default: 20 }
 *     responses:
 *       200:
 *         description: List of colleges
 */
router.route('/')
  .post(upload.single('logo'), createCollegeValidator, createCollege)
  .get(getColleges);

/**
 * @swagger
 * /college/{id}:
 *   get:
 *     summary: Get college by ID
 *     tags: [Colleges]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: College data
 *       404:
 *         description: Not found
 *   put:
 *     summary: Update college
 *     tags: [Colleges]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name: { type: string }
 *               code: { type: string }
 *               address: { type: string }
 *               email: { type: string }
 *               phone: { type: string }
 *               principalName: { type: string }
 *               status: { type: string, enum: [active, inactive] }
 *               logo: { type: string, format: binary }
 *     responses:
 *       200:
 *         description: College updated
 *   delete:
 *     summary: Delete college
 *     tags: [Colleges]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: College deleted
 */
router.route('/:id')
  .get(getCollege)
  .put(upload.single('logo'), updateCollegeValidator, updateCollege)
  .delete(deleteCollege);

export default router;
