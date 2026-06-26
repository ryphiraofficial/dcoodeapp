import mongoose from 'mongoose';

const collegeSchema = new mongoose.Schema(
  {
    name: { type: String, required: [true, 'College name is required'], trim: true },
    code: { type: String, required: [true, 'College code is required'], unique: true, uppercase: true, trim: true },
    address: { type: String, trim: true },
    email: { type: String, lowercase: true, trim: true, match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'] },
    phone: { type: String, trim: true },
    principalName: { type: String, trim: true },
    logo: { type: String, default: null },        // R2 public URL
    logoKey: { type: String, default: null },     // R2 object key (for deletion)
    status: { type: String, enum: ['active', 'inactive'], default: 'active' },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Staff' },
  },
  { timestamps: true }
);

collegeSchema.index({ name: 'text', code: 'text' });

const College = mongoose.model('College', collegeSchema);
export default College;
