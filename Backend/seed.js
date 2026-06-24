/**
 * Seed Script — Creates an initial Staff account
 * Run with: npm run seed
 */
import 'dotenv/config';
import mongoose from 'mongoose';
import Staff from './src/models/Staff.js';
import connectDB from './src/config/db.js';

const seed = async () => {
  await connectDB();

  const email = 'admin@college.com';
  const password = 'Admin@1234';
  const name = 'Super Admin';

  const existing = await Staff.findOne({ email });
  if (existing) {
    console.log(`⚠️  Staff account already exists: ${email}`);
    process.exit(0);
  }

  await Staff.create({ name, email, password, phone: '9999999999' });

  console.log('\n✅ Seed completed successfully!');
  console.log('─────────────────────────────────────');
  console.log(`  Role    : Staff`);
  console.log(`  Email   : ${email}`);
  console.log(`  Password: ${password}`);
  console.log('─────────────────────────────────────');
  console.log('⚠️  Change this password after first login!\n');

  await mongoose.disconnect();
  process.exit(0);
};

seed().catch((err) => {
  console.error('❌ Seed failed:', err.message);
  process.exit(1);
});
