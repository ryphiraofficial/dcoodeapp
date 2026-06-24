import 'dotenv/config';
import mongoose from 'mongoose';
import Student from './src/models/Student.js';
import connectDB from './src/config/db.js';

const test = async () => {
  await connectDB();
  const res = await Student.deleteOne({ email: 'soulhyper960@gmail.com' });
  console.log('Deleted?', res.deletedCount);
  process.exit(0);
};

test();
