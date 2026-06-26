import { body } from 'express-validator';

export const bulkAttendanceValidator = [
  body('batch')
    .notEmpty()
    .withMessage('Batch ID is required')
    .isMongoId()
    .withMessage('Invalid Batch ID'),
  body('date')
    .notEmpty()
    .withMessage('Date is required')
    .isISO8601()
    .withMessage('Invalid date format. Use YYYY-MM-DD'),
  body('records')
    .isArray({ min: 1 })
    .withMessage('Records must be a non-empty array'),
  body('records.*.student')
    .notEmpty()
    .withMessage('Student ID is required in records')
    .isMongoId()
    .withMessage('Invalid Student ID in records'),
  body('records.*.status')
    .notEmpty()
    .withMessage('Status is required in records')
    .isIn(['Present', 'Absent', 'Late', 'Leave'])
    .withMessage('Status must be Present, Absent, Late, or Leave'),
  body('task')
    .optional()
    .isString()
    .withMessage('Task must be a string'),
  body('description')
    .optional()
    .isString()
    .withMessage('Description must be a string'),
  body('files')
    .optional()
    .isArray()
    .withMessage('Files must be an array of strings'),
  body('files.*')
    .optional()
    .isString()
    .withMessage('Each file must be a string'),
];

export const markLeaveValidator = [
  body('date')
    .notEmpty()
    .withMessage('Date is required')
    .isISO8601()
    .withMessage('Invalid date format. Use YYYY-MM-DD'),
  body('batchId')
    .optional()
    .isMongoId()
    .withMessage('Invalid Batch ID'),
];
