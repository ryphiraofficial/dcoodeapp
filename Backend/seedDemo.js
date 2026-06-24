/**
 * Demo Seed Script
 * Creates: 1 College, 2 Courses, 2 Batches, 2 Staff, 10 Students
 * Run with: node seedDemo.js
 */
import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import connectDB from './src/config/db.js';

import Staff from './src/models/Staff.js';
import Student from './src/models/Student.js';
import College from './src/models/College.js';
import Course from './src/models/Course.js';
import Batch from './src/models/Batch.js';

// ─── Helper ───────────────────────────────────────────────────────────────────
const genStudentId = (n) => `STD${String(n).padStart(6, '0')}`;

const hashPw = async (pw) => bcrypt.hash(pw, parseInt(process.env.BCRYPT_ROUNDS) || 12);

// ─── Data ─────────────────────────────────────────────────────────────────────

const STAFF_DATA = [
  {
    name: 'Rohith Kumar',
    email: 'rohith@dcoode.com',
    password: 'Staff@1234',
    phone: '9876543210',
  },
  {
    name: 'Priya Sharma',
    email: 'priya@dcoode.com',
    password: 'Staff@1234',
    phone: '9876543211',
  },
];

const STUDENT_PLAIN_PASSWORDS = [
  'Pass@0001', 'Pass@0002', 'Pass@0003', 'Pass@0004', 'Pass@0005',
  'Pass@0006', 'Pass@0007', 'Pass@0008', 'Pass@0009', 'Pass@0010',
];

const STUDENTS_RAW = [
  { fullName: 'Arjun Mehta',     registerNumber: 'REG2024001', rollNumber: '01', email: 'arjun@student.dcoode.com',   phone: '9000000001', gender: 'Male',   dateOfBirth: '2003-04-12', parentName: 'Vijay Mehta',   parentPhone: '9100000001' },
  { fullName: 'Sneha Patel',     registerNumber: 'REG2024002', rollNumber: '02', email: 'sneha@student.dcoode.com',   phone: '9000000002', gender: 'Female', dateOfBirth: '2003-07-22', parentName: 'Ravi Patel',    parentPhone: '9100000002' },
  { fullName: 'Mohammed Ali',    registerNumber: 'REG2024003', rollNumber: '03', email: 'ali@student.dcoode.com',     phone: '9000000003', gender: 'Male',   dateOfBirth: '2002-11-05', parentName: 'Hamid Ali',     parentPhone: '9100000003' },
  { fullName: 'Divya Nair',      registerNumber: 'REG2024004', rollNumber: '04', email: 'divya@student.dcoode.com',   phone: '9000000004', gender: 'Female', dateOfBirth: '2003-02-18', parentName: 'Suresh Nair',   parentPhone: '9100000004' },
  { fullName: 'Karthik Rajan',   registerNumber: 'REG2024005', rollNumber: '05', email: 'karthik@student.dcoode.com', phone: '9000000005', gender: 'Male',   dateOfBirth: '2002-09-30', parentName: 'Rajan Kumar',   parentPhone: '9100000005' },
  { fullName: 'Ananya Singh',    registerNumber: 'REG2024006', rollNumber: '06', email: 'ananya@student.dcoode.com',  phone: '9000000006', gender: 'Female', dateOfBirth: '2003-06-14', parentName: 'Anil Singh',    parentPhone: '9100000006' },
  { fullName: 'Rahul Verma',     registerNumber: 'REG2024007', rollNumber: '07', email: 'rahul@student.dcoode.com',   phone: '9000000007', gender: 'Male',   dateOfBirth: '2002-12-25', parentName: 'Sunil Verma',   parentPhone: '9100000007' },
  { fullName: 'Meera Krishnan',  registerNumber: 'REG2024008', rollNumber: '08', email: 'meera@student.dcoode.com',   phone: '9000000008', gender: 'Female', dateOfBirth: '2003-03-08', parentName: 'Siva Krishnan', parentPhone: '9100000008' },
  { fullName: 'Aditya Sharma',   registerNumber: 'REG2024009', rollNumber: '09', email: 'aditya@student.dcoode.com',  phone: '9000000009', gender: 'Male',   dateOfBirth: '2002-08-19', parentName: 'Deepak Sharma', parentPhone: '9100000009' },
  { fullName: 'Lakshmi Reddy',   registerNumber: 'REG2024010', rollNumber: '10', email: 'lakshmi@student.dcoode.com', phone: '9000000010', gender: 'Female', dateOfBirth: '2003-01-27', parentName: 'Naidu Reddy',   parentPhone: '9100000010' },
];

// ─── Main ─────────────────────────────────────────────────────────────────────
const seed = async () => {
  await connectDB();

  console.log('\n🌱 Starting demo seed...\n');

  // ── 1. College ──────────────────────────────────────────────────────────────
  let college = await College.findOne({ code: 'DCEC' });
  if (!college) {
    college = await College.create({
      name: 'Dcoode Engineering College',
      code: 'DCEC',
      address: '42 Tech Park, Bengaluru, Karnataka - 560001',
      email: 'info@dcec.edu.in',
      phone: '08012345678',
      principalName: 'Dr. Arun Prasad',
      status: 'active',
    });
    console.log(`✅ College created: ${college.name}`);
  } else {
    console.log(`⚠️  College already exists: ${college.name}`);
  }

  // ── 2. Courses ──────────────────────────────────────────────────────────────
  let bcaCourse = await Course.findOne({ code: 'BCA' });
  if (!bcaCourse) {
    bcaCourse = await Course.create({
      name: 'Bachelor of Computer Applications',
      code: 'BCA',
      duration: '3 Years',
      numberOfSemesters: 6,
      description: 'Undergraduate program in computer applications and software development.',
      college: college._id,
    });
    console.log(`✅ Course created: ${bcaCourse.name}`);
  } else {
    console.log(`⚠️  Course already exists: ${bcaCourse.name}`);
  }

  let mbaCourse = await Course.findOne({ code: 'MBA' });
  if (!mbaCourse) {
    mbaCourse = await Course.create({
      name: 'Master of Business Administration',
      code: 'MBA',
      duration: '2 Years',
      numberOfSemesters: 4,
      description: 'Postgraduate management program focused on leadership and business strategy.',
      college: college._id,
    });
    console.log(`✅ Course created: ${mbaCourse.name}`);
  } else {
    console.log(`⚠️  Course already exists: ${mbaCourse.name}`);
  }

  // ── 3. Batches ──────────────────────────────────────────────────────────────
  let bcaBatch = await Batch.findOne({ name: 'BCA 2024-2027 Batch A' });
  if (!bcaBatch) {
    bcaBatch = await Batch.create({
      name: 'BCA 2024-2027 Batch A',
      college: college._id,
      course: bcaCourse._id,
      facultyName: 'Prof. Ramesh Kumar',
      startDate: new Date('2024-06-01'),
      endDate: new Date('2027-05-31'),
      workingDays: 'Monday-Friday',
    });
    console.log(`✅ Batch created: ${bcaBatch.name}`);
  } else {
    console.log(`⚠️  Batch already exists: ${bcaBatch.name}`);
  }

  let mbaBatch = await Batch.findOne({ name: 'MBA 2024-2026 Batch A' });
  if (!mbaBatch) {
    mbaBatch = await Batch.create({
      name: 'MBA 2024-2026 Batch A',
      college: college._id,
      course: mbaCourse._id,
      facultyName: 'Prof. Sunita Rao',
      startDate: new Date('2024-07-01'),
      endDate: new Date('2026-06-30'),
      workingDays: 'Monday-Friday',
    });
    console.log(`✅ Batch created: ${mbaBatch.name}`);
  } else {
    console.log(`⚠️  Batch already exists: ${mbaBatch.name}`);
  }

  // ── 4. Staff ────────────────────────────────────────────────────────────────
  console.log('\n👨‍💼 Creating Staff...\n');
  const createdStaff = [];
  for (const s of STAFF_DATA) {
    const existing = await Staff.findOne({ email: s.email });
    if (existing) {
      console.log(`⚠️  Staff already exists: ${s.email}`);
      createdStaff.push({ ...s, skipped: true });
    } else {
      await Staff.create(s); // password hashed by pre-save hook
      console.log(`✅ Staff: ${s.name} | ${s.email} | Password: ${s.password}`);
      createdStaff.push(s);
    }
  }

  // ── 5. Students ─────────────────────────────────────────────────────────────
  console.log('\n🎓 Creating Students...\n');

  // Count existing students for ID generation
  let existingCount = await Student.countDocuments();
  const createdStudents = [];

  for (let i = 0; i < STUDENTS_RAW.length; i++) {
    const s = STUDENTS_RAW[i];
    const plainPassword = STUDENT_PLAIN_PASSWORDS[i];

    const existing = await Student.findOne({ email: s.email });
    if (existing) {
      console.log(`⚠️  Student already exists: ${s.email}`);
      continue;
    }

    existingCount++;
    const studentId = genStudentId(existingCount);
    // Alternate between BCA and MBA batches (first 6 → BCA, last 4 → MBA)
    const batch  = i < 6 ? bcaBatch  : mbaBatch;
    const course = i < 6 ? bcaCourse : mbaCourse;

    await Student.create({
      ...s,
      studentId,
      password: plainPassword, // hashed by pre-save hook
      college: college._id,
      course: course._id,
      batch: batch._id,
      address: `${i + 1} Main Road, Bengaluru`,
    });

    console.log(`✅ ${studentId} | ${s.fullName.padEnd(18)} | ${s.email.padEnd(32)} | Password: ${plainPassword}`);
    createdStudents.push({ studentId, ...s, password: plainPassword });
  }

  // ── Summary ─────────────────────────────────────────────────────────────────
  console.log('\n' + '─'.repeat(70));
  console.log('✅  SEED COMPLETE\n');
  console.log('🏫 College  : Dcoode Engineering College (DCEC)');
  console.log('📚 Courses  : BCA (6 sem) | MBA (4 sem)');
  console.log('🗂️  Batches  : BCA 2024-2027 Batch A | MBA 2024-2026 Batch A');
  console.log('\n👨‍💼 STAFF CREDENTIALS');
  console.log('─'.repeat(50));
  for (const s of STAFF_DATA) {
    console.log(`  ${s.name.padEnd(20)} | ${s.email.padEnd(28)} | ${s.password}`);
  }
  console.log('\n🎓 STUDENT CREDENTIALS');
  console.log('─'.repeat(70));
  for (let i = 0; i < STUDENTS_RAW.length; i++) {
    const s = STUDENTS_RAW[i];
    const id = genStudentId(i + 1); // approximate — may differ if existing data
    console.log(`  ${id} | ${s.fullName.padEnd(18)} | ${s.email.padEnd(34)} | ${STUDENT_PLAIN_PASSWORDS[i]}`);
  }
  console.log('─'.repeat(70));
  console.log('\n⚠️  Save these credentials! Passwords are hashed in DB.\n');

  await mongoose.disconnect();
  process.exit(0);
};

seed().catch((err) => {
  console.error('❌ Seed failed:', err.message);
  process.exit(1);
});
