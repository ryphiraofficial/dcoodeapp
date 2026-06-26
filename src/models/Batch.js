import mongoose from 'mongoose';

const batchSchema = new mongoose.Schema(
  {
    name: { type: String, required: [true, 'Batch name is required'], trim: true },
    college: { type: mongoose.Schema.Types.ObjectId, ref: 'College', required: [true, 'College is required'] },
    course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: [true, 'Course is required'] },
    facultyInCharge: { type: String, trim: true },
    duration: { type: String, required: [true, 'Duration is required'] },
    startDate: { type: Date, required: [true, 'Start date is required'] },
    endDate: { type: Date },
    startTime: { type: String, trim: true },
    endTime: { type: String, trim: true },
    workingDays: { type: String, enum: ['Monday-Friday', 'Weekend', 'Custom'], default: 'Monday-Friday' },
    customWorkingDays: { type: [String], default: [] },
    isActive: { type: Boolean, default: true },
    certificateDescription: { type: String, trim: true, default: '' },
  },
  { timestamps: true }
);

const Batch = mongoose.model('Batch', batchSchema);
export default Batch;
