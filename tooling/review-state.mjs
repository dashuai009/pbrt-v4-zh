// Source content and included assets must still match the independently reviewed snapshot.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
export const sha256 = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
export function assessReview(file, record, root = process.cwd()) {
  const resolve = name => path.resolve(root, name);
  if (!fs.existsSync(resolve(file))) return {status: 'missing', changes: [file]};
  if (!fs.readFileSync(resolve(file), 'utf8').trim()) return {status: 'empty', changes: [file]};
  if (!record) return {status: 'not_reviewed', changes: []};
  const changes = [];
  if (record.status !== "source_compared_and_independently_reviewed") changes.push("review verdict not established");
  if (!record.source || !record.source_sha256) changes.push("missing source snapshot");
  for (const [name, hash] of Object.entries({[file]: record.local_sha256, ...record.included_files})) {
    if (!fs.existsSync(resolve(name)) || sha256(fs.readFileSync(resolve(name))) !== hash) changes.push(name);
  }
  for (const report of [record.editor_report, record.independent_review_report]) {
    if (!report || !fs.existsSync(resolve(report))) changes.push(report || 'missing review report');
  }
  if (record.editor_report === record.independent_review_report) changes.push('editor and independent report are the same');
  if (record.source && record.source_sha256) {
    const original = resolve('pbr-book-website/' + record.source);
    if (!fs.existsSync(original) || sha256(fs.readFileSync(original)) !== record.source_sha256) changes.push(record.source);
  }
  return {status: changes.length ? 'changed_since_review' : 'independently_reviewed', changes};
}
export const reviewLabel = state => ({
  missing:'缺失', empty:'空文件', not_reviewed:'待原文对照及独立复核',
  changed_since_review:'复核后内容或依赖变化，需复查', independently_reviewed:'已原文对照及独立复核（源问题见报告）',
})[state.status];
