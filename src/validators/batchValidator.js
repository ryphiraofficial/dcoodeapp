import { body } from 'express-validator';

export const createBatchValidator = [
  body('name').notEmpty().withMessage('Batch name is required').trim(),
  body('facultyInCharge').optional().isString().trim(),
  body('college').isMongoId().withMessage('Valid college ID is required'),
  body('course').isMongoId().withMessage('Valid course ID is required'),
  body('duration').notEmpty().withMessage('Duration is required').trim(),
  body('startDate').isISO8601().withMessage('Valid start date is required'),
  body('endDate').optional().isISO8601().withMessage('Valid end date must be a date'),
  body('startTime').optional().isString().trim(),
  body('endTime').optional().isString().trim(),
  body('workingDays').optional().isIn(['Monday-Friday', 'Weekend', 'Custom']).withMessage('Invalid working days value'),
  body('customWorkingDays').optional().isArray().withMessage('customWorkingDays must be an array'),
];

export const updateBatchValidator = [
  body('name').optional().notEmpty().withMessage('Batch name cannot be empty').trim(),
  body('facultyInCharge').optional().isString().trim(),
  body('college').optional().isMongoId().withMessage('Valid college ID is required'),
  body('course').optional().isMongoId().withMessage('Valid course ID is required'),
  body('duration').optional().notEmpty().withMessage('Duration cannot be empty').trim(),
  body('startDate').optional().isISO8601().withMessage('Valid start date is required'),
  body('endDate').optional().isISO8601().withMessage('Valid end date must be a date'),
  body('startTime').optional().isString().trim(),
  body('endTime').optional().isString().trim(),
  body('workingDays').optional().isIn(['Monday-Friday', 'Weekend', 'Custom']).withMessage('Invalid working days value'),
  body('customWorkingDays').optional().isArray().withMessage('customWorkingDays must be an array'),
];
