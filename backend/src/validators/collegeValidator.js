import { body } from 'express-validator';

export const createCollegeValidator = [
  body('name').notEmpty().withMessage('College name is required').trim(),
  body('code').notEmpty().withMessage('College code is required').trim(),
  body('email').optional().isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional().matches(/^[0-9+\-\s()]{7,15}$/).withMessage('Invalid phone number'),
  body('status').optional().isIn(['active', 'inactive']).withMessage('Status must be active or inactive'),
];

export const updateCollegeValidator = [
  body('name').optional().notEmpty().withMessage('College name cannot be empty').trim(),
  body('code').optional().notEmpty().withMessage('College code cannot be empty').trim(),
  body('address').optional().trim(),
  body('email').optional().isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional().matches(/^[0-9+\-\s()]{7,15}$/).withMessage('Invalid phone number'),
  body('principalName').optional().trim(),
  body('status').optional().isIn(['active', 'inactive']).withMessage('Status must be active or inactive'),
];
