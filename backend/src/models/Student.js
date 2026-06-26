import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

const studentSchema = new mongoose.Schema(
  {
    studentId: { type: String, unique: true },
    fullName: { type: String, required: [true, 'Full name is required'], trim: true },
    registerNumber: { type: String, required: [true, 'Register number is required'], unique: true, trim: true },
    rollNumber: { type: String, trim: true },
    email: {
      type: String, required: [true, 'Email is required'], unique: true,
      lowercase: true, trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    phone: { type: String, trim: true },
    dateOfBirth: { type: Date },
    gender: { type: String, enum: ['Male', 'Female', 'Other'] },
    address: { type: String, trim: true },
    photo: { type: String, default: null },        // R2 public URL
    photoKey: { type: String, default: null },      // R2 object key (for deletion)
    certifications: [
      {
        name: { type: String, required: true, trim: true },
        url: { type: String, required: true },      // R2 public URL
        key: { type: String, required: true },      // R2 object key
        uploadedAt: { type: Date, default: Date.now },
      },
    ],
    parentName: { type: String, trim: true },
    parentPhone: { type: String, trim: true },
    college: { type: mongoose.Schema.Types.ObjectId, ref: 'College', required: [true, 'College is required'] },
    course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: [true, 'Course is required'] },
    batch: { type: mongoose.Schema.Types.ObjectId, ref: 'Batch', required: [true, 'Batch is required'] },
    password: { type: String, required: true, select: false },
    role: { type: String, default: 'student', enum: ['student'] },
    refreshToken: { type: String, select: false },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

studentSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, parseInt(process.env.BCRYPT_ROUNDS) || 12);
  next();
});

studentSchema.methods.comparePassword = async function (candidatePassword) {
  console.log(candidatePassword);
  
  return bcrypt.compare(candidatePassword, this.password);
};

studentSchema.index({ fullName: 'text', registerNumber: 'text', studentId: 'text' });

const Student = mongoose.model('Student', studentSchema);
export default Student;
