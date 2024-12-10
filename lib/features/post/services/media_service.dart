import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/media_model.dart';

class MediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  Future<MediaModel> uploadMedia(File file, String userId) async {
    try {
      // 파일 확장자 확인
      final String extension = file.path.split('.').last.toLowerCase();
      final bool isVideo = ['mp4', 'mov', 'avi'].contains(extension);
      final String mediaType = isVideo ? 'video' : 'image';
      
      // 저장할 경로 생성
      final String fileName = '${_uuid.v4()}.$extension';
      final String path = 'media/$userId/$fileName';
      
      // Storage에 업로드
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      
      // 업로드 진행 상태 모니터링
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: $progress%');
      });

      // 업로드 완료 대기
      await uploadTask;
      
      // 다운로드 URL 가져오기
      final String downloadUrl = await ref.getDownloadURL();
      
      // MediaModel 생성 및 반환
      return MediaModel(
        id: fileName,
        url: downloadUrl,
        type: mediaType,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error uploading media: $e');
      rethrow;
    }
  }

  Future<void> deleteMedia(String userId, String mediaId) async {
    try {
      final ref = _storage.ref().child('media/$userId/$mediaId');
      await ref.delete();
    } catch (e) {
      print('Error deleting media: $e');
      rethrow;
    }
  }
}
