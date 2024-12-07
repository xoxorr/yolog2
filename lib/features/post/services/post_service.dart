import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/post_repository.dart';
import '../models/post_model.dart';

class PostService extends ChangeNotifier {
  final FirebaseAuth _auth;
  final PostRepository _postRepository;
  final FirebaseFirestore _firestore;

  PostService({
    required FirebaseAuth auth,
    required PostRepository postRepository,
  })  : _auth = auth,
        _postRepository = postRepository,
        _firestore = FirebaseFirestore.instance;

  String? validatePost(PostModel post) {
    if (post.title.isEmpty) {
      return '제목을 입력해주세요';
    }
    if (post.content.isEmpty) {
      return '내용을 입력해주세요';
    }
    if (_auth.currentUser == null) {
      return '로그인이 필요합니다';
    }
    return null;
  }

  // 게시글 생성
  Future<String> createPost(PostModel post) async {
    final error = validatePost(post);
    if (error != null) {
      throw Exception(error);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다');
    }

    // 사용자 정보 가져오기
    final userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    final userName = userDoc.data()?['displayName'] as String? ??
        currentUser.displayName ??
        '익명';
    final photoUrl =
        userDoc.data()?['photoURL'] as String? ?? currentUser.photoURL;

    // 사용자 정보를 포함한 새 게시글 생성
    final newPost = post.copyWith(
      authorId: currentUser.uid,
      authorName: userName,
      authorPhotoUrl: photoUrl,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 게시글 저장 후 ID 반환
    return _postRepository.createPost(newPost);
  }

  // 게시글 수정
  Future<void> updatePost(PostModel post) async {
    final error = validatePost(post);
    if (error != null) {
      throw Exception(error);
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다');
    }

    if (post.authorId != currentUser.uid) {
      throw Exception('자신의 게시글만 수정할 수 있습니다');
    }

    await _postRepository.updatePost(post.copyWith(
      updatedAt: DateTime.now(),
    ));
  }

  // 게시글 삭제
  Future<void> deletePost(String postId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('로그인이 필요합니다');
    }

    final post = await _postRepository.getPost(postId);
    if (post == null) {
      throw Exception('게시글을 찾을 수 없습니다');
    }

    if (post.authorId != currentUser.uid) {
      throw Exception('자신의 게시글만 삭제할 수 있습니다');
    }

    await _postRepository.deletePost(postId);
  }

  // 게시글 스트림
  Stream<List<PostModel>> getPostsStream() {
    return _postRepository.getPostsStream();
  }

  // 단일 게시글 조회
  Future<PostModel?> getPost(String postId) {
    return _postRepository.getPost(postId);
  }
}
