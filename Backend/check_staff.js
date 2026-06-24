import 'dotenv/config';
import mongoose from 'mongoose';
import Staff from './src/models/Staff.js';
import connectDB from './src/config/db.js';

const test = async () => {
  await connectDB();
  const staff = await Staff.find({}, 'email name').lean();
  console.log('Staff in DB:');
  console.log(staff);
  process.exit(0);
};

test();
