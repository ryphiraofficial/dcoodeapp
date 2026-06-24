import { Router } from 'express';
import { createCourse, getCourses, getCoursesByCollege, getCourse, updateCourse, deleteCourse } from '../controllers/courseController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import { createCourseValidator, updateCourseValidator } from '../validators/courseValidator.js';

const router = Router();
router.use(protect, staffOnly);

/**
 * @swagger
 * tags:
 *   name: Courses
 *   description: Course management
 */

/**
 * @swagger
 * /course:
 *   post:
 *     summary: Create a new course
 *     tags: [Courses]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, code, durations, college]
 *             properties:
 *               name: { type: string }
 *               code: { type: string }
 *               durations: { type: array, items: { type: string } }
 *               description: { type: string }
 *               college: { type: string, description: College ObjectId }
 *     responses:
 *       201:
 *         description: Course created
 *   get:
 *     summary: Get all courses
 *     tags: [Courses]
 *     parameters:
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *       - in: query
 *         name: collegeId
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of courses
 */
router.route('/').post(createCourseValidator, createCourse).get(getCourses);

/**
 * @swagger
 * /course/{collegeId}:
 *   get:
 *     summary: Get courses by college ID
 *     tags: [Courses]
 *     parameters:
 *       - in: path
 *         name: collegeId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Courses for the college
 */
router.get('/:collegeId', getCoursesByCollege);

/**
 * @swagger
 * /course/{id}:
 *   put:
 *     summary: Update course
 *     tags: [Courses]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Course updated
 *   delete:
 *     summary: Delete course
 *     tags: [Courses]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Course deleted
 */
router.route('/:id').put(updateCourseValidator, updateCourse).delete(deleteCourse);

export default router;
