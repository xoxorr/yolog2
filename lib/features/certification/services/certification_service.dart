import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certification_model.dart';

class CertificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 인증 게시물 생성
  Future<void> createCertification({
    required String userId,
    required String title,
    required String content,
    required List<String> imageUrls,
    required GeoPoint location,
    String? category,
  }) async {
    try {
      final certification = CertificationModel(
        userId: userId,
        title: title,
        content: content,
        imageUrls: imageUrls,
        location: location,
        category: category,
        createdAt: DateTime.now(),
        likes: 0,
        comments: 0,
      );

      await _firestore.collection('certifications').add(certification.toMap());
    } catch (e) {
      throw Exception('인증 게시물 생성에 실패했습니다: $e');
    }
  }

  // 인증 게시물 수정
  Future<void> updateCertification({
    required String certificationId,
    String? title,
    String? content,
    List<String>? imageUrls,
    GeoPoint? location,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (imageUrls != null) updateData['imageUrls'] = imageUrls;
      if (location != null) updateData['location'] = location;
      if (category != null) updateData['category'] = category;
      updateData['updatedAt'] = DateTime.now();

      await _firestore
          .collection('certifications')
          .doc(certificationId)
          .update(updateData);
    } catch (e) {
      throw Exception('인증 게시물 수정에 실패했습니다: $e');
    }
  }

  // 인증 게시물 삭제
  Future<void> deleteCertification(String certificationId) async {
    try {
      await _firestore
          .collection('certifications')
          .doc(certificationId)
          .delete();
    } catch (e) {
      throw Exception('인증 게시물 삭제에 실패했습니다: $e');
    }
  }

  // 특정 인증 게시물 조회
  Future<CertificationModel?> getCertification(String certificationId) async {
    try {
      final doc = await _firestore
          .collection('certifications')
          .doc(certificationId)
          .get();

      if (doc.exists) {
        return CertificationModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('인증 게시물 조회에 실패했습니다: $e');
    }
  }

  // 모든 인증 게시물 조회 (페이지네이션)
  Stream<List<CertificationModel>> getCertifications({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) {
    try {
      var query = _firestore
          .collection('certifications')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => CertificationModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('인증 게시물 목록 조회에 실패했습니다: $e');
    }
  }

  // 특정 사용자의 인증 게시물 조회
  Stream<List<CertificationModel>> getUserCertifications(String userId) {
    try {
      return _firestore
          .collection('certifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => CertificationModel.fromMap(doc.data()))
            .toList();
      });
    } catch (e) {
      throw Exception('사용자의 인증 게시물 조회에 실패했습니다: $e');
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(String certificationId, String userId) async {
    try {
      final likeRef = _firestore
          .collection('certifications')
          .doc(certificationId)
          .collection('likes')
          .doc(userId);

      final likeDoc = await likeRef.get();
      final certificationRef =
          _firestore.collection('certifications').doc(certificationId);

      await _firestore.runTransaction((transaction) async {
        if (likeDoc.exists) {
          await likeRef.delete();
          await certificationRef.update({'likes': FieldValue.increment(-1)});
        } else {
          await likeRef.set({'userId': userId, 'createdAt': DateTime.now()});
          await certificationRef.update({'likes': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('좋아요 처리에 실패했습니다: $e');
    }
  }

  // 댓글 추가
  Future<void> addComment({
    required String certificationId,
    required String userId,
    required String content,
  }) async {
    try {
      final commentData = {
        'userId': userId,
        'content': content,
        'createdAt': DateTime.now(),
      };

      final certificationRef =
          _firestore.collection('certifications').doc(certificationId);

      await _firestore.runTransaction((transaction) async {
        await certificationRef.collection('comments').add(commentData);
        await certificationRef.update({
          'comments': FieldValue.increment(1),
        });
      });
    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }
}
