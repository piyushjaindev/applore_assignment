import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseProducts {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  DocumentSnapshot? _lastDocument;

  Future<void> addProduct(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users/$userId/products')
        .add(data)
        .catchError((e) => throw e);
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot = await _firestore
        .collection('users/$userId/products')
        .limit(10)
        .get()
        .catchError((e) => throw e);

    if (querySnapshot.docs.length > 0) _lastDocument = querySnapshot.docs.last;
    return querySnapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMoreProducts(String userId) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot = await _firestore
        .collection('users/$userId/products')
        .startAfterDocument(_lastDocument!)
        .limit(10)
        .get()
        .catchError((e) => throw e);

    if (querySnapshot.docs.length > 0) _lastDocument = querySnapshot.docs.last;
    return querySnapshot.docs.map((docSnapshot) => docSnapshot.data()).toList();
  }

  Future<String> uploadFile(File file, String filename) async {
    final task =
        await _storage.ref(filename).putFile(file).catchError((e) => throw e);
    return task.ref.getDownloadURL();
  }
}
