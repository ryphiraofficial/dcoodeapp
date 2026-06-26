import { Router } from 'express';
import {
  createStaff, getStaffList, getStaff,
  updateStaff, deleteStaff, getMyProfile, updateMyProfile
} from '../controllers/staffController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import {
  createStaffValidator, updateStaffValidator,
} from '../validators/staffValidator.js';

const router = Router();
router.use(protect);

/**
 * @swagger
 * tags:
 *   name: Staff
 *   description: Staff management
 */

/**
 * @swagger
 * /staff/me:
 *   get:
 *     summary: Get logged-in staff's own profile
 *     tags: [Staff]
 *     responses:
 *       200:
 *         description: Staff profile
 *   put:
 *     summary: Update logged-in staff's own profile
 *     tags: [Staff]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name: { type: string }
 *               email: { type: string, format: email }
 *               phone: { type: string }
 *     responses:
 *       200:
 *         description: Profile updated successfully
 */
router.route('/me')
  .get(getMyProfile)
  .put(updateStaffValidator, updateMyProfile);

// Ensure all subsequent routes are only accessible by Staff
router.use(staffOnly);

/**
 * @swagger
 * /staff:
 *   post:
 *     summary: Create a new staff member
 *     tags: [Staff]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email]
 *             properties:
 *               name: { type: string }
 *               email: { type: string, format: email }
 *               phone: { type: string }
 *               password: { type: string }
 *     responses:
 *       201:
 *         description: Staff created with temporary password
 *   get:
 *     summary: Get all staff members
 *     tags: [Staff]
 *     parameters:
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of staff
 */
router.route('/')
  .post(createStaffValidator, createStaff)
  .get(getStaffList);

/**
 * @swagger
 * /staff/{id}:
 *   get:
 *     summary: Get staff member by ID
 *     tags: [Staff]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Staff data
 *   put:
 *     summary: Update staff member
 *     tags: [Staff]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name: { type: string }
 *               email: { type: string, format: email }
 *               phone: { type: string }
 *               isActive: { type: boolean }
 *     responses:
 *       200:
 *         description: Staff updated
 *   delete:
 *     summary: Delete staff member
 *     tags: [Staff]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Staff deleted
 */
router.route('/:id')
  .get(getStaff)
  .put(updateStaffValidator, updateStaff)
  .delete(deleteStaff);

export default router;
