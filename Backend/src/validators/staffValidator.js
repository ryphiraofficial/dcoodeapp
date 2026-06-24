import { body } from 'express-validator';

const phoneRegex = /^[0-9+\-\s()]{7,15}$/;

export const createStaffValidator = [
  body('name').notEmpty().withMessage('Name is required').trim(),
  body('email').isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional({ checkFalsy: true }).matches(phoneRegex).withMessage('Invalid phone number'),
];

export const updateStaffValidator = [
  body('name').optional().notEmpty().withMessage('Name cannot be empty').trim(),
  body('email').optional().isEmail().withMessage('Valid email is required').normalizeEmail(),
  body('phone').optional({ checkFalsy: true }).matches(phoneRegex).withMessage('Invalid phone number'),
];
