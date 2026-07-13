import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class TicketAttachmentStorage {
  TicketAttachmentStorage._();

  static Future<String?> pickAndStoreImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) {
      return null;
    }

    final sourcePath = result.files.single.path;
    if (sourcePath == null || sourcePath.isEmpty) {
      throw const FileSystemException('Selected image path is unavailable.');
    }

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('Selected image no longer exists.');
    }

    final directory = await _attachmentDirectory();
    await directory.create(recursive: true);
    final safeName = path
        .basename(sourcePath)
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final destination = path.join(
      directory.path,
      '${DateTime.now().microsecondsSinceEpoch}_$safeName',
    );
    return (await source.copy(destination)).path;
  }

  static Future<void> deleteManagedFile(String? filePath) async {
    if (filePath == null || filePath.isEmpty) {
      return;
    }

    final directory = await _attachmentDirectory();
    final normalizedFile = path.normalize(path.absolute(filePath));
    final normalizedDirectory = path.normalize(path.absolute(directory.path));
    if (!path.isWithin(normalizedDirectory, normalizedFile)) {
      return;
    }

    final file = File(normalizedFile);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<Directory> _attachmentDirectory() async {
    final databaseDirectory = await getDatabasesPath();
    return Directory(path.join(databaseDirectory, 'ticket_attachments'));
  }
}
