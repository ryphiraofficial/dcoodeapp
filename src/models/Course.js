import mongoose from 'mongoose';

const courseSchema = new mongoose.Schema(
  {
    name: { type: String, required: [true, 'Course name is required'], trim: true },
    code: { type: String, required: [true, 'Course code is required'], unique: true, uppercase: true, trim: true },
    durations: [{ type: String, trim: true }],
    description: { type: String, trim: true },
    college: { type: mongoose.Schema.Types.ObjectId, ref: 'College', required: [true, 'College is required'] },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

courseSchema.index({ name: 'text', code: 'text' });

const Course = mongoose.model('Course', courseSchema);
export default Course;
