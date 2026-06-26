import { body } from 'express-validator';

const phoneRegex = /^[0-9+\-\s()]{7,15}$/;

export const createStudentValidator = [
  body('fullName').notEmpty().withMessage('Full name is required').trim(),
  body('registerNumber').notEmpty().withMessage('Register number is required').trim(),
  body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional().matches(phoneRegex).withMessage('Invalid phone number'),
  body('gender').optional().isIn(['Male', 'Female', 'Other']).withMessage('Invalid gender'),
  body('college').isMongoId().withMessage('Valid college ID is required'),
  body('course').isMongoId().withMessage('Valid course ID is required'),
  body('batch').isMongoId().withMessage('Valid batch ID is required'),
];

export const updateStudentValidator = [
  body('fullName').optional().notEmpty().withMessage('Full name cannot be empty').trim(),
  body('email').optional().isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional().matches(phoneRegex).withMessage('Invalid phone number'),
  body('gender').optional().isIn(['Male', 'Female', 'Other']).withMessage('Invalid gender'),
  body('college').optional().isMongoId().withMessage('Valid college ID is required'),
  body('course').optional().isMongoId().withMessage('Valid course ID is required'),
  body('batch').optional().isMongoId().withMessage('Valid batch ID is required'),
];

export const studentSelfUpdateValidator = [
  body('phone').optional().matches(phoneRegex).withMessage('Invalid phone number'),
  body('address').optional().trim(),
  body('parentName').optional().trim(),
  body('parentPhone').optional().matches(phoneRegex).withMessage('Invalid parent phone number'),
];
