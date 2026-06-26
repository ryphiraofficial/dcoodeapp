import { body } from 'express-validator';

const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;

export const createTimetableValidator = [
  body('batch').isMongoId().withMessage('Valid batch ID is required'),
  body('subject').notEmpty().withMessage('Subject is required').trim(),
  body('faculty').notEmpty().withMessage('Faculty is required').trim(),
  body('date').isISO8601().withMessage('Valid date is required'),
  body('startTime').notEmpty().withMessage('Start time is required').matches(timeRegex).withMessage('Start time must be HH:MM format'),
  body('endTime').notEmpty().withMessage('End time is required').matches(timeRegex).withMessage('End time must be HH:MM format'),
];

export const updateTimetableValidator = [
  body('batch').optional().isMongoId().withMessage('Valid batch ID is required'),
  body('date').optional().isISO8601().withMessage('Valid date is required'),
  body('startTime').optional().matches(timeRegex).withMessage('Start time must be HH:MM format'),
  body('endTime').optional().matches(timeRegex).withMessage('End time must be HH:MM format'),
];
