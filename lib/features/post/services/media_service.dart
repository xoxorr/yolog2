import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/media_model.dart';

class MediaService {
  final FirebaseStorage _storage;
  final ImagePicker _picker;
  final String _storagePath = 'posts';

  MediaService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _picker = picker ?? ImagePicker();

  // 이미지 선택 (갤러리)
  Future<List<File>> pickImages({int maxImages = 10}) async {
    final pickedFiles = await _picker.pickMultiImage();

    return pickedFiles
        .map((xFile) => File(xFile.path))
        .take(maxImages)
        .toList();
  }

  // 비디오 선택 (갤러리)
  Future<File?> pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  // 이미지 촬영
  Future<File?> takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  // 비디오 촬영
  Future<File?> takeVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  // 미디어 업로드
  Future<MediaModel> uploadMedia(
    File file,
    MediaType type,
    String userId,
  ) async {
    final id = const Uuid().v4();
    final extension = file.path.split('.').last;
    final path = '$_storagePath/$userId/$id.$extension';

    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;

    final url = await snapshot.ref.getDownloadURL();
    String? thumbnail;

    if (type == MediaType.video) {
      // TODO: Generate video thumbnail
      thumbnail = null;
    }

    return MediaModel(
      id: id,
      url: url,
      type: type,
      thumbnail: thumbnail,
    );
  }

  // 미디어 삭제
  Future<void> deleteMedia(String userId, String mediaId) async {
    try {
      final ref = _storage.ref().child('$_storagePath/$userId/$mediaId');
      await ref.delete();
    } catch (e) {
      print('Error deleting media: $e');
    }
  }

  // 미디어 파일 검증
  String? validateMediaFile(File file, MediaType type) {
    final size = file.lengthSync();
    final extension = file.path.split('.').last.toLowerCase();

    if (type == MediaType.image) {
      if (size > 10 * 1024 * 1024) {
        // 10MB
        return '이미지 크기는 10MB를 초과할 수 없습니다.';
      }

      if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
        return '지원하지 않는 이미지 형식입니다. (jpg, jpeg, png, gif만 지원)';
      }
    } else if (type == MediaType.video) {
      if (size > 100 * 1024 * 1024) {
        // 100MB
        return '비디오 크기는 100MB를 초과할 수 없습니다.';
      }

      if (!['mp4', 'mov', 'avi'].contains(extension)) {
        return '지원하지 않는 비디오 형식입니다. (mp4, mov, avi만 지원)';
      }
    }

    return null;
  }
}
