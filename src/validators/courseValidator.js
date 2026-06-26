import { body } from 'express-validator';

export const createCourseValidator = [
  body('name').notEmpty().withMessage('Course name is required').trim(),
  body('code').notEmpty().withMessage('Course code is required').trim(),
  body('durations').isArray({ min: 1 }).withMessage('At least one duration is required'),
  body('durations.*').isString().withMessage('Each duration must be a string').trim().notEmpty(),
  body('college').isMongoId().withMessage('Valid college ID is required'),
];

export const updateCourseValidator = [
  body('name').optional().notEmpty().withMessage('Course name cannot be empty').trim(),
  body('durations').optional().isArray({ min: 1 }).withMessage('At least one duration is required'),
  body('durations.*').optional().isString().withMessage('Each duration must be a string').trim().notEmpty(),
  body('college').optional().isMongoId().withMessage('Valid college ID is required'),
];
