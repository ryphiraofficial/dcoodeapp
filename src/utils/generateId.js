import Student from '../models/Student.js';
import Certificate from '../models/Certificate.js';

/** Generates a unique Student ID in format: STD000001 */
export const generateStudentId = async () => {
  const count = await Student.countDocuments();
  const nextNum = count + 1;
  const padded = String(nextNum).padStart(6, '0');
  return `STD${padded}`;
};

/** Generates a unique Certificate ID in format: CERT-00001 */
export const generateCertificateId = async () => {
  const count = await Certificate.countDocuments();
  const nextNum = count + 1;
  const padded = String(nextNum).padStart(5, '0');
  return `CERT-${padded}`;
};
