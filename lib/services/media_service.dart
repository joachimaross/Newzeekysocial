import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum MediaType { image, video, audio, document, voice_note }
enum MediaQuality { low, medium, high, original }

class MediaMetadata {
  final int? width;
  final int? height;
  final int? duration; // in milliseconds
  final int fileSize;
  final String mimeType;
  final String originalName;
  final Map<String, dynamic> exifData;
  final String? thumbnailUrl;

  MediaMetadata({
    this.width,
    this.height,
    this.duration,
    required this.fileSize,
    required this.mimeType,
    required this.originalName,
    this.exifData = const {},
    this.thumbnailUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'width': width,
      'height': height,
      'duration': duration,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'originalName': originalName,
      'exifData': exifData,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory MediaMetadata.fromMap(Map<String, dynamic> map) {
    return MediaMetadata(
      width: map['width'],
      height: map['height'],
      duration: map['duration'],
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'] ?? '',
      originalName: map['originalName'] ?? '',
      exifData: Map<String, dynamic>.from(map['exifData'] ?? {}),
      thumbnailUrl: map['thumbnailUrl'],
    );
  }
}

class MediaUploadResult {
  final String url;
  final String thumbnailUrl;
  final MediaMetadata metadata;
  final String storageRef;

  MediaUploadResult({
    required this.url,
    required this.thumbnailUrl,
    required this.metadata,
    required this.storageRef,
  });
}

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload image with optional compression
  Future<MediaUploadResult?> uploadImage(
    XFile imageFile, {
    MediaQuality quality = MediaQuality.medium,
    bool generateThumbnail = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final file = File(imageFile.path);
      final fileBytes = await file.readAsBytes();
      
      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = 'images/${user.uid}/$timestamp.$extension';

      // Upload original image
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = await storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'uploadedBy': user.uid,
            'originalName': imageFile.name,
            'quality': quality.toString().split('.').last,
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Generate thumbnail
      String thumbnailUrl = downloadUrl;
      if (generateThumbnail) {
        thumbnailUrl = await _generateThumbnail(fileBytes, fileName) ?? downloadUrl;
      }

      // Get metadata
      final metadata = MediaMetadata(
        fileSize: fileBytes.length,
        mimeType: 'image/$extension',
        originalName: imageFile.name,
        thumbnailUrl: thumbnailUrl,
      );

      return MediaUploadResult(
        url: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        metadata: metadata,
        storageRef: fileName,
      );
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Upload video with thumbnail generation
  Future<MediaUploadResult?> uploadVideo(
    XFile videoFile, {
    bool generateThumbnail = true,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final file = File(videoFile.path);
      final fileBytes = await file.readAsBytes();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = videoFile.path.split('.').last;
      final fileName = 'videos/${user.uid}/$timestamp.$extension';

      final storageRef = _storage.ref().child(fileName);
      final uploadTask = await storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: 'video/$extension',
          customMetadata: {
            'uploadedBy': user.uid,
            'originalName': videoFile.name,
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Generate video thumbnail
      String thumbnailUrl = '';
      if (generateThumbnail) {
        // In a real implementation, you'd extract the first frame
        // For now, use a placeholder or the video URL
        thumbnailUrl = downloadUrl;
      }

      final metadata = MediaMetadata(
        fileSize: fileBytes.length,
        mimeType: 'video/$extension',
        originalName: videoFile.name,
        thumbnailUrl: thumbnailUrl,
      );

      return MediaUploadResult(
        url: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        metadata: metadata,
        storageRef: fileName,
      );
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }

  // Upload audio file
  Future<MediaUploadResult?> uploadAudio(
    File audioFile, {
    int? duration,
    bool isVoiceNote = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final fileBytes = await audioFile.readAsBytes();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = audioFile.path.split('.').last;
      final folder = isVoiceNote ? 'voice_notes' : 'audio';
      final fileName = '$folder/${user.uid}/$timestamp.$extension';

      final storageRef = _storage.ref().child(fileName);
      final uploadTask = await storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: 'audio/$extension',
          customMetadata: {
            'uploadedBy': user.uid,
            'isVoiceNote': isVoiceNote.toString(),
            'duration': duration?.toString() ?? '',
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final metadata = MediaMetadata(
        fileSize: fileBytes.length,
        mimeType: 'audio/$extension',
        originalName: audioFile.path.split('/').last,
        duration: duration,
      );

      return MediaUploadResult(
        url: downloadUrl,
        thumbnailUrl: '', // Audio doesn't need thumbnails
        metadata: metadata,
        storageRef: fileName,
      );
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }

  // Upload document/file
  Future<MediaUploadResult?> uploadDocument(File documentFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final fileBytes = await documentFile.readAsBytes();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = documentFile.path.split('.').last;
      final fileName = 'documents/${user.uid}/$timestamp.$extension';

      final storageRef = _storage.ref().child(fileName);
      final uploadTask = await storageRef.putData(
        fileBytes,
        SettableMetadata(
          customMetadata: {
            'uploadedBy': user.uid,
            'originalName': documentFile.path.split('/').last,
          },
        ),
      );

      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final metadata = MediaMetadata(
        fileSize: fileBytes.length,
        mimeType: _getMimeTypeFromExtension(extension),
        originalName: documentFile.path.split('/').last,
      );

      return MediaUploadResult(
        url: downloadUrl,
        thumbnailUrl: _getDocumentIcon(extension),
        metadata: metadata,
        storageRef: fileName,
      );
    } catch (e) {
      print('Error uploading document: $e');
      return null;
    }
  }

  // Generate thumbnail (placeholder implementation)
  Future<String?> _generateThumbnail(Uint8List imageBytes, String originalPath) async {
    try {
      // In a real implementation, you would:
      // 1. Resize the image to thumbnail size
      // 2. Compress it
      // 3. Upload to a thumbnails folder
      // 4. Return the thumbnail URL
      
      final thumbnailPath = originalPath.replaceFirst('images/', 'thumbnails/');
      final storageRef = _storage.ref().child(thumbnailPath);
      
      // For now, just upload the same image as thumbnail
      // In production, implement proper image resizing
      await storageRef.putData(imageBytes);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  // Delete media from storage
  Future<bool> deleteMedia(String storageRef) async {
    try {
      await _storage.ref().child(storageRef).delete();
      
      // Also try to delete thumbnail if it exists
      final thumbnailRef = storageRef.replaceFirst('images/', 'thumbnails/');
      try {
        await _storage.ref().child(thumbnailRef).delete();
      } catch (_) {
        // Thumbnail might not exist, ignore error
      }
      
      return true;
    } catch (e) {
      print('Error deleting media: $e');
      return false;
    }
  }

  // Get media picker options
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickImage(source: source);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<XFile?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      return await _picker.pickVideo(source: source);
    } catch (e) {
      print('Error picking video: $e');
      return null;
    }
  }

  Future<List<XFile>?> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage();
    } catch (e) {
      print('Error picking multiple images: $e');
      return null;
    }
  }

  // Utility methods
  String _getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  String _getDocumentIcon(String extension) {
    // Return appropriate document icon based on file type
    switch (extension.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📋';
      case 'zip':
      case 'rar':
        return '🗜️';
      default:
        return '📎';
    }
  }

  // Check file size limits
  bool isFileSizeValid(int fileSize, MediaType type) {
    const int maxImageSize = 10 * 1024 * 1024; // 10MB
    const int maxVideoSize = 100 * 1024 * 1024; // 100MB
    const int maxAudioSize = 20 * 1024 * 1024; // 20MB
    const int maxDocumentSize = 50 * 1024 * 1024; // 50MB

    switch (type) {
      case MediaType.image:
        return fileSize <= maxImageSize;
      case MediaType.video:
        return fileSize <= maxVideoSize;
      case MediaType.audio:
      case MediaType.voice_note:
        return fileSize <= maxAudioSize;
      case MediaType.document:
        return fileSize <= maxDocumentSize;
    }
  }
}