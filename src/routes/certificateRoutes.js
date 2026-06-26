import { Router } from 'express';
import { generate, generateBulk, getMyCertificate, getCertificate, getByBatch, verify, getBatchInfo } from '../controllers/certificateController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Certificate
 *   description: Dynamic Certificate Generation
 */

/**
 * @swagger
 * /certificate/verify/{certificateId}:
 *   get:
 *     summary: Verify a certificate (Public)
 *     tags: [Certificate]
 *     parameters:
 *       - in: path
 *         name: certificateId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Verification details
 *       404:
 *         description: Invalid Certificate
 */
router.get('/verify/:certificateId', verify);

// Ensure subsequent routes are protected
router.use(protect);

/**
 * @swagger
 * /certificate/me:
 *   get:
 *     summary: Get the logged-in student's own certificate
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Certificate details (studentName from DB, certificateId, description, etc.)
 *       404:
 *         description: No certificate issued yet
 */
router.get('/me', getMyCertificate);

/**
 * @swagger
 * /certificate/batch-info:
 *   get:
 *     summary: Get the logged-in student's batch name and certificate description
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Returns batchId, batchName, and certificateDescription
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 info:
 *                   type: object
 *                   properties:
 *                     batchId:
 *                       type: string
 *                     batchName:
 *                       type: string
 *                     certificateDescription:
 *                       type: string
 *       404:
 *         description: Student or batch not found
 */
router.get('/batch-info', getBatchInfo);

/**
 * @swagger
 * /certificate/generate/{studentId}:
 *   post:
 *     summary: Generate a new certificate for a student (Staff only)
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: studentId
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               description:
 *                 type: string
 *                 example: "This is to certify that the student has successfully completed the course."
 *     responses:
 *       201:
 *         description: Certificate generated successfully
 */
router.post('/generate/:studentId', staffOnly, generate);

/**
 * @swagger
 * /certificate/generate/batch/{batchId}:
 *   post:
 *     summary: Generate certificates for ALL students in a batch (Staff only)
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: batchId
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [description]
 *             properties:
 *               description:
 *                 type: string
 *                 example: "This is to certify that the student has successfully completed the course."
 *     responses:
 *       201:
 *         description: Certificates generated for the batch
 */
router.post('/generate/batch/:batchId', staffOnly, generateBulk);

/**
 * @swagger
 * /certificate/batch/{batchId}:
 *   get:
 *     summary: Get all certificates for a specific batch
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: batchId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of generated certificates for the batch
 */
router.get('/batch/:batchId', getByBatch);

/**
 * @swagger
 * /certificate/{studentId}:
 *   get:
 *     summary: Get certificate details to build PDF (for a specific student)
 *     tags: [Certificate]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: studentId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Formatted certificate JSON for PDF generation
 */
router.get('/:studentId', getCertificate);

export default router;
