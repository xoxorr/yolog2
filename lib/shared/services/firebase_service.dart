import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseStorage get storage => FirebaseStorage.instance;

  Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await firestore.collection(collection).add(data);
  }

  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) async {
    await firestore.collection(collection).doc(documentId).delete();
  }

  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    return await firestore.collection(collection).doc(documentId).get();
  }

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return firestore.collection(collection).snapshots();
  }

  Future<String> uploadFile(String path, List<int> data) async {
    final ref = storage.ref().child(path);
    await ref.putData(data);
    return await ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    await storage.ref().child(path).delete();
  }
}
