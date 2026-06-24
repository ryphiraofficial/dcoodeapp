import 'dotenv/config';
import mongoose from 'mongoose';
import * as studentService from './src/services/studentService.js';
import College from './src/models/College.js';
import Course from './src/models/Course.js';
import Batch from './src/models/Batch.js';
import connectDB from './src/config/db.js';

const test = async () => {
  try {
    await connectDB();
    const college = await College.findOne();
    const course = await Course.findOne();
    const batch = await Batch.findOne();

    if (!college || !course || !batch) {
      console.log('Missing college, course, or batch. Cannot create student.');
      process.exit(1);
    }

    const newStudent = {
      fullName: 'Soul Hyper',
      registerNumber: 'REG' + Date.now().toString().slice(-6),
      email: 'soulhyper960@gmail.com',
      college: college._id,
      course: course._id,
      batch: batch._id,
    };

    console.log('Creating student...');
    const result = await studentService.create(newStudent);
    console.log('Student created successfully!');
    console.log('Check your email inbox at soulhyper960@gmail.com');
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
};

test();
