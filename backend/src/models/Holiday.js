import mongoose from 'mongoose';

const holidaySchema = new mongoose.Schema(
  {
    date: { type: Date, required: [true, 'Date is required'] },
    reason: { type: String, trim: true, default: 'Leave' },
    batch: { type: mongoose.Schema.Types.ObjectId, ref: 'Batch', default: null }, // If null, applies to all batches
    markedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Staff', required: true },
  },
  { timestamps: true }
);

// Ensure only one holiday per date per batch (or global)
holidaySchema.index({ date: 1, batch: 1 }, { unique: true });

const Holiday = mongoose.model('Holiday', holidaySchema);
export default Holiday;
