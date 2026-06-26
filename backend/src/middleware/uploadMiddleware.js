import multer from 'multer';
import path from 'path';

// Use memory storage — files are uploaded to R2, not disk
const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedImage = /jpeg|jpg|png|gif|webp/;
  const allowedDoc = /pdf|doc|docx/;
  const ext = path.extname(file.originalname).toLowerCase().replace('.', '');

  if (allowedImage.test(ext) || allowedDoc.test(ext)) {
    return cb(null, true);
  }
  cb(new Error('Allowed file types: images (jpeg, jpg, png, gif, webp) and documents (pdf, doc, docx)'));
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 5 * 1024 * 1024, // 5MB
  },
});

export default upload;
