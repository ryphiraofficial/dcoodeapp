import 'dotenv/config';
import mongoose from 'mongoose';
import Student from './src/models/Student.js';
import connectDB from './src/config/db.js';

const test = async () => {
  await connectDB();
  const email = 'arjun@student.dcoode.com';
  const password = 'Pass@0001';
  
  const student = await Student.findOne({ email }).select('+password');
  console.log('Student found:', student ? 'Yes' : 'No');
  
  if (student) {
    console.log('Is Active:', student.isActive);
    const isMatch = await student.comparePassword(password);
    console.log('Password Match:', isMatch);
  }
  
  process.exit(0);
};

test();
