import mongoose from 'mongoose';

const timetableSchema = new mongoose.Schema(
  {
    batch: { type: mongoose.Schema.Types.ObjectId, ref: 'Batch', required: [true, 'Batch is required'] },
    subject: { type: String, required: [true, 'Subject is required'], trim: true },
    faculty: { type: String, required: [true, 'Faculty is required'], trim: true },
    date: { type: Date, required: [true, 'Date is required'] },
    startTime: { type: String, required: [true, 'Start time is required'] },
    endTime: { type: String, required: [true, 'End time is required'] },
    classroom: { type: String, trim: true },
  },
  { timestamps: true }
);

timetableSchema.index({ batch: 1, date: 1 });

const Timetable = mongoose.model('Timetable', timetableSchema);
export default Timetable;
