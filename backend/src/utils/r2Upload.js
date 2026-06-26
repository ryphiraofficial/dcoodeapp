import { PutObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import path from 'path';
import r2Client from '../config/r2.js';

/**
 * Uploads a file buffer to Cloudflare R2
 * @param {Buffer} buffer - File buffer from multer memoryStorage
 * @param {string} originalName - Original file name (for extension)
 * @param {string} folder - Folder: 'photos' | 'logos' | 'certifications'
 * @returns {Promise<{ key: string, url: string }>}
 */
export const uploadToR2 = async (buffer, originalName, folder = 'misc') => {
  const ext = path.extname(originalName).toLowerCase();
  const uniqueName = `${folder}/${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
  const bucket = process.env.R2_BUCKET_NAME;

  await r2Client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: uniqueName,
      Body: buffer,
      ContentType: getMimeType(ext),
      // R2 public bucket — no ACL needed
    })
  );

  const url = `${process.env.R2_PUBLIC_URL}/${uniqueName}`;
  return { key: uniqueName, url };
};

/**
 * Deletes a file from Cloudflare R2 by its key
 * @param {string} key - The R2 object key (e.g. 'photos/123456.jpg')
 */
export const deleteFromR2 = async (key) => {
  if (!key) return;
  try {
    await r2Client.send(
      new DeleteObjectCommand({
        Bucket: process.env.R2_BUCKET_NAME,
        Key: key,
      })
    );
  } catch (err) {
    console.error(`⚠️  R2 delete failed for key "${key}":`, err.message);
  }
};

/**
 * Extracts the R2 key from a full public URL
 * e.g. https://pub-xxx.r2.dev/photos/123.jpg → photos/123.jpg
 */
export const extractR2Key = (url) => {
  if (!url) return null;
  const base = process.env.R2_PUBLIC_URL;
  if (url.startsWith(base)) {
    return url.replace(`${base}/`, '');
  }
  return null;
};

const getMimeType = (ext) => {
  const types = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.webp': 'image/webp',
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };
  return types[ext] || 'application/octet-stream';
};
