import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/draft_model.dart';

class LocalRepository {
  final SharedPreferences _prefs;
  final String _draftKey = 'local_drafts';

  LocalRepository(this._prefs);

  // 로컬 임시저장 게시글 저장
  Future<void> saveDraftLocally(DraftModel draft) async {
    final drafts = await getLocalDrafts();
    final draftIndex = drafts.indexWhere((d) => d.id == draft.id);

    if (draftIndex != -1) {
      drafts[draftIndex] = draft;
    } else {
      drafts.add(draft);
    }

    final jsonList = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs.setStringList(_draftKey, jsonList);
  }

  // 로컬 임시저장 게시글 가져오기
  Future<List<DraftModel>> getLocalDrafts() async {
    final jsonList = _prefs.getStringList(_draftKey) ?? [];
    return jsonList
        .map((json) => DraftModel.fromJson(jsonDecode(json)))
        .toList();
  }

  // 로컬 임시저장 게시글 삭제
  Future<void> deleteLocalDraft(String draftId) async {
    final drafts = await getLocalDrafts();
    drafts.removeWhere((draft) => draft.id == draftId);

    final jsonList = drafts.map((d) => jsonEncode(d.toJson())).toList();
    await _prefs.setStringList(_draftKey, jsonList);
  }

  // 모든 로컬 임시저장 게시글 삭제
  Future<void> clearAllLocalDrafts() async {
    await _prefs.remove(_draftKey);
  }

  // 특정 사용자의 로컬 임시저장 게시글 가져오기
  Future<List<DraftModel>> getUserLocalDrafts(String userId) async {
    final allDrafts = await getLocalDrafts();
    return allDrafts.where((draft) => draft.userId == userId).toList();
  }
}
