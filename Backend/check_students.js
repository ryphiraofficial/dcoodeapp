import 'dotenv/config';
import mongoose from 'mongoose';
import Student from './src/models/Student.js';
import connectDB from './src/config/db.js';

const test = async () => {
  await connectDB();
  const students = await Student.find({}, 'email fullName').lean();
  console.log('Students in DB:');
  console.log(students);
  process.exit(0);
};

test();
