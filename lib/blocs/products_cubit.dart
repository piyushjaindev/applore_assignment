import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as IM;
import 'package:path_provider/path_provider.dart' as PATH;

import '../firebase/products.dart';
import '../models/product_model.dart';

abstract class ProductsCubitStates {}

class ProductsCubitInitial extends ProductsCubitStates {}

class ProductsCubitLoading extends ProductsCubitStates {}

class ProductsCubitFetching extends ProductsCubitStates {}

class ProductsCubitFetched extends ProductsCubitStates {
  final List<ProductModel> products;
  ProductsCubitFetched(this.products);
}

class ProductsCubitFailed extends ProductsCubitStates {}

class ProductsCubitSuccess extends ProductsCubitStates {}

class ProductsCubit extends Cubit<ProductsCubitStates> {
  ProductsCubit() : super(ProductsCubitInitial());
  final FirebaseProducts _firebaseProducts = FirebaseProducts();
  final uuid = Uuid();
  late String _filename;

  Future<File> compressImage(File image) async {
    _filename = 'img_${uuid.v4()}.jpg';
    final tempDir = await PATH.getTemporaryDirectory();
    final tempPath = tempDir.path;
    final decodedImage = IM.decodeImage(image.readAsBytesSync());
    final compressedImage = IM.encodeJpg(decodedImage!, quality: 70);
    return File('$tempPath/$_filename')..writeAsBytesSync(compressedImage);
  }

  Future<String> _uploadImage(File file) async {
    return await _firebaseProducts
        .uploadFile(file, _filename)
        .catchError((e) => throw e);
  }

  void addProduct(
      {required String name,
      required String description,
      required String price,
      required File image,
      required String userId}) async {
    emit(ProductsCubitLoading());
    try {
      String imageURL = await _uploadImage(image);
      ProductModel product = ProductModel(
          name: name, description: description, image: imageURL, price: price);
      await _addProduct(userId, product);
      emit(ProductsCubitSuccess());
    } catch (e) {
      emit(ProductsCubitFailed());
    }
  }

  Future<void> _addProduct(String userId, ProductModel product) async {
    return await _firebaseProducts
        .addProduct(userId, product.toMap())
        .catchError((e) => throw e);
  }

  void fetchProducts(String userId, {bool fromStart = true}) async {
    List<ProductModel> products = [];
    emit(ProductsCubitFetching());
    try {
      List<Map<String, dynamic>>? result;
      if (fromStart)
        result = await _firebaseProducts.fetchProducts(userId);
      else
        result = await _firebaseProducts.fetchMoreProducts(userId);
      for (var data in result) {
        products.add(ProductModel.fromMap(data));
      }
      emit(ProductsCubitFetched(products));
    } catch (_) {
      emit(ProductsCubitFailed());
      //throw _;
    }
  }
}
