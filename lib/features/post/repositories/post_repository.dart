import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'posts';

  // 게시글 생성
  Future<String> createPost(PostModel post) async {
    final docRef = _firestore.collection(_collection).doc();
    await docRef.set(post.copyWith(id: docRef.id).toJson());
    return docRef.id;
  }

  // 게시글 수정
  Future<void> updatePost(PostModel post) async {
    await _firestore
        .collection(_collection)
        .doc(post.id)
        .update(post.toJson());
  }

  // 게시글 삭제 (소프트 삭제)
  Future<void> deletePost(String postId) async {
    await _firestore
        .collection(_collection)
        .doc(postId)
        .update({'isDeleted': true});
  }

  // 게시글 스트림
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection(_collection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // 단일 게시글 조회
  Future<PostModel?> getPost(String postId) async {
    final doc = await _firestore.collection(_collection).doc(postId).get();
    if (!doc.exists) return null;
    return PostModel.fromJson({...doc.data()!, 'id': doc.id});
  }
}
