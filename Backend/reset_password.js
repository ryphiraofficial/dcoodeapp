import 'dotenv/config';
import mongoose from 'mongoose';
import Staff from './src/models/Staff.js';
import connectDB from './src/config/db.js';

const resetPassword = async () => {
  await connectDB();
  const email = 'mridul@gmail.com';
  const newPassword = 'Staff@1234';
  
  const staff = await Staff.findOne({ email });
  if (staff) {
    staff.password = newPassword;
    await staff.save();
    console.log(`Password for ${email} has been reset to: ${newPassword}`);
  } else {
    console.log('Staff not found');
  }
  process.exit(0);
};

resetPassword();
