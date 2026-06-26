import { Router } from 'express';
import {
  createStudent, getStudents, getStudent,
  updateStudent, deleteStudent, getMyProfile,
  uploadCertification, deleteCertification,
} from '../controllers/studentController.js';
import { protect, staffOnly } from '../middleware/authMiddleware.js';
import upload from '../middleware/uploadMiddleware.js';
import {
  createStudentValidator, updateStudentValidator, studentSelfUpdateValidator,
} from '../validators/studentValidator.js';

const router = Router();
router.use(protect);

/**
 * @swagger
 * tags:
 *   name: Students
 *   description: Student management
 */

/**
 * @swagger
 * /student/me:
 *   get:
 *     summary: Get logged-in student's own profile
 *     tags: [Students]
 *     responses:
 *       200:
 *         description: Student profile
 */
router.get('/me', getMyProfile);

/**
 * @swagger
 * /student:
 *   post:
 *     summary: Create a new student (Staff only)
 *     tags: [Students]
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required: [fullName, registerNumber, email, college, course, batch]
 *             properties:
 *               fullName: { type: string }
 *               registerNumber: { type: string }
 *               rollNumber: { type: string }
 *               email: { type: string }
 *               phone: { type: string }
 *               dateOfBirth: { type: string, format: date }
 *               gender: { type: string, enum: [Male, Female, Other] }
 *               address: { type: string }
 *               parentName: { type: string }
 *               parentPhone: { type: string }
 *               college: { type: string }
 *               course: { type: string }
 *               batch: { type: string }
 *               photo: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: Student created with temporary password
 *   get:
 *     summary: Get all students (Staff only)
 *     tags: [Students]
 *     parameters:
 *       - in: query
 *         name: search
 *         schema: { type: string }
 *       - in: query
 *         name: collegeId
 *         schema: { type: string }
 *       - in: query
 *         name: courseId
 *         schema: { type: string }
 *       - in: query
 *         name: batchId
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: List of students
 */
router.route('/')
  .post(staffOnly, upload.single('photo'), createStudentValidator, createStudent)
  .get(staffOnly, getStudents);

/**
 * @swagger
 * /student/{id}:
 *   get:
 *     summary: Get student by ID (Staff gets any; Student gets own only)
 *     tags: [Students]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Student data
 *   put:
 *     summary: Update student (Staff full access; Student limited fields only)
 *     tags: [Students]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Student updated
 *   delete:
 *     summary: Delete student (Staff only)
 *     tags: [Students]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Student deleted
 */
router.route('/:id')
  .get(getStudent)
  .put(upload.single('photo'), updateStudentValidator, studentSelfUpdateValidator, updateStudent)
  .delete(staffOnly, deleteStudent);

/**
 * @swagger
 * /student/{id}/certifications:
 *   post:
 *     summary: Upload a certification document (Student or Staff)
 *     tags: [Students]
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
 *             required: [name, file]
 *             properties:
 *               name: { type: string, example: AWS Cloud Practitioner }
 *               file: { type: string, format: binary }
 *     responses:
 *       201:
 *         description: Certification uploaded to R2 and saved
 *
 * /student/{id}/certifications/{certId}:
 *   delete:
 *     summary: Delete a certification (Student own or Staff)
 *     tags: [Students]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *       - in: path
 *         name: certId
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Certification deleted from R2 and DB
 */
router.post('/:id/certifications', upload.single('file'), uploadCertification);
router.delete('/:id/certifications/:certId', deleteCertification);

export default router;
