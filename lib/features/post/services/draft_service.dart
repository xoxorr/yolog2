import '../models/draft_model.dart';
import '../repositories/post_repository.dart';
import '../repositories/local_repository.dart';

class DraftService {
  final PostRepository _postRepository;
  final LocalRepository _localRepository;

  DraftService({
    required PostRepository postRepository,
    required LocalRepository localRepository,
  })  : _postRepository = postRepository,
        _localRepository = localRepository;

  // 임시저장 게시글 저장 (온라인)
  Future<String> saveDraft(DraftModel draft) async {
    return await _postRepository.saveDraft(draft);
  }

  // 임시저장 게시글 저장 (로컬)
  Future<void> saveDraftLocally(DraftModel draft) async {
    await _localRepository.saveDraftLocally(draft);
  }

  // 임시저장 게시글 가져오기 (온라인)
  Future<List<DraftModel>> getUserDrafts(String userId) async {
    return await _postRepository.getUserDrafts(userId);
  }

  // 임시저장 게시글 가져오기 (로컬)
  Future<List<DraftModel>> getLocalDrafts(String userId) async {
    return await _localRepository.getUserLocalDrafts(userId);
  }

  // 모든 임시저장 게시글 가져오기 (온라인 + 로컬)
  Future<List<DraftModel>> getAllDrafts(String userId) async {
    final onlineDrafts = await getUserDrafts(userId);
    final localDrafts = await getLocalDrafts(userId);

    final allDrafts = [...onlineDrafts, ...localDrafts];
    allDrafts.sort((a, b) => b.lastSaved.compareTo(a.lastSaved));

    return allDrafts;
  }

  // 임시저장 게시글 삭제 (온라인)
  Future<void> deleteDraft(String draftId) async {
    await _postRepository.deleteDraft(draftId);
  }

  // 임시저장 게시글 삭제 (로컬)
  Future<void> deleteLocalDraft(String draftId) async {
    await _localRepository.deleteLocalDraft(draftId);
  }

  // 모든 로컬 임시저장 게시글 삭제
  Future<void> clearAllLocalDrafts() async {
    await _localRepository.clearAllLocalDrafts();
  }

  // 임시저장 게시글을 온라인으로 동기화
  Future<void> syncLocalDrafts(String userId) async {
    final localDrafts = await getLocalDrafts(userId);

    for (final draft in localDrafts) {
      await saveDraft(draft);
      await deleteLocalDraft(draft.id);
    }
  }
}
