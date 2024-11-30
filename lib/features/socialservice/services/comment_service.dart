import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'comments';

  // 댓글 작성
  Future<CommentModel> addComment(
    String userId,
    String contentId,
    String content, {
    String? parentId,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final comment = CommentModel(
        id: docRef.id,
        userId: userId,
        contentId: contentId,
        parentId: parentId,
        content: content,
        createdAt: DateTime.now(),
      );

      await _firestore.runTransaction((transaction) async {
        transaction.set(docRef, comment.toJson());

        // 부모 댓글이 있는 경우 답글 수 증가
        if (parentId != null) {
          final parentRef = _firestore.collection(_collection).doc(parentId);
          final parentDoc = await transaction.get(parentRef);
          if (parentDoc.exists) {
            transaction.update(parentRef, {
              'replyCount': FieldValue.increment(1),
            });
          }
        }

        // 콘텐츠의 댓글 수 증가
        final contentRef = _firestore.collection('posts').doc(contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'commentCount': FieldValue.increment(1),
          });
        }
      });

      return comment;
    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  // 댓글 수정
  Future<CommentModel> updateComment(String commentId, String content) async {
    try {
      final docRef = _firestore.collection(_collection).doc(commentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('댓글을 찾을 수 없습니다.');
      }

      final updatedComment = CommentModel.fromJson(doc.data()!).copyWith(
        content: content,
        updatedAt: DateTime.now(),
        isEdited: true,
      );

      await docRef.update(updatedComment.toJson());
      return updatedComment;
    } catch (e) {
      throw Exception('댓글 수정에 실패했습니다: $e');
    }
  }

  // 댓글 삭제
  Future<void> deleteComment(String commentId) async {
    try {
      final docRef = _firestore.collection(_collection).doc(commentId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('댓글을 찾을 수 없습니다.');
      }

      final comment = CommentModel.fromJson(doc.data()!);

      await _firestore.runTransaction((transaction) async {
        // 소프트 삭제로 처리
        transaction.update(docRef, {
          'isDeleted': true,
          'content': '삭제된 댓글입니다.',
        });

        // 부모 댓글이 있는 경우 답글 수 감소
        if (comment.parentId != null) {
          final parentRef =
              _firestore.collection(_collection).doc(comment.parentId);
          final parentDoc = await transaction.get(parentRef);
          if (parentDoc.exists) {
            transaction.update(parentRef, {
              'replyCount': FieldValue.increment(-1),
            });
          }
        }

        // 콘텐츠의 댓글 수 감소
        final contentRef =
            _firestore.collection('posts').doc(comment.contentId);
        final contentDoc = await transaction.get(contentRef);
        if (contentDoc.exists) {
          transaction.update(contentRef, {
            'commentCount': FieldValue.increment(-1),
          });
        }
      });
    } catch (e) {
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  // 댓글 목록 가져오기
  Future<List<CommentModel>> getComments(
    String contentId, {
    String? lastCommentId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('contentId', isEqualTo: contentId)
          .where('parentId', isNull: true) // 최상위 댓글만 가져오기
          .orderBy('createdAt', descending: true)
          .withConverter<CommentModel>(
            fromFirestore: (snapshot, _) =>
                CommentModel.fromJson(snapshot.data()!),
            toFirestore: (comment, _) => comment.toJson(),
          );

      if (lastCommentId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastCommentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('댓글 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 답글 목록 가져오기
  Future<List<CommentModel>> getReplies(
    String parentId, {
    String? lastReplyId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('parentId', isEqualTo: parentId)
          .orderBy('createdAt', descending: true)
          .withConverter<CommentModel>(
            fromFirestore: (snapshot, _) =>
                CommentModel.fromJson(snapshot.data()!),
            toFirestore: (comment, _) => comment.toJson(),
          );

      if (lastReplyId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastReplyId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('답글 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 사용자의 댓글 목록 가져오기
  Future<List<CommentModel>> getUserComments(
    String userId, {
    String? lastCommentId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .withConverter<CommentModel>(
            fromFirestore: (snapshot, _) =>
                CommentModel.fromJson(snapshot.data()!),
            toFirestore: (comment, _) => comment.toJson(),
          );

      if (lastCommentId != null) {
        final lastDoc =
            await _firestore.collection(_collection).doc(lastCommentId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('사용자의 댓글 목록을 가져오는데 실패했습니다: $e');
    }
  }
}
