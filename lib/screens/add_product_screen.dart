import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/products_cubit.dart';
import '../blocs/auth_cubit.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? _name, _description, _price;
  File? _imageFile, _compressedImageFile;

  final _formKey = GlobalKey<FormState>();

  void _pickImage() async {
    PickedFile? image = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxWidth: 240);
    if (image != null)
      setState(() {
        _imageFile = File(image.path);
      });
  }

  void _confirmAddProduct() async {
    setState(() {
      _formKey.currentState?.save();
    });
    if ((_formKey.currentState?.validate() ?? false) && _imageFile != null) {
      _compressedImageFile =
          await context.read<ProductsCubit>().compressImage(_imageFile!);
      showDialog(
          context: context,
          builder: (context) {
            return _buildAlertDialog(context);
          });
    }
  }

  void _addProduct() {
    context.read<ProductsCubit>().addProduct(
        name: _name!,
        description: _description!,
        price: _price!,
        image: _compressedImageFile!,
        userId: context.read<AuthCubit>().state.user.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<ProductsCubit, ProductsCubitStates>(
          listener: (context, state) {
        if (state is ProductsCubitFailed)
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Somethng went wrong!')));
        else if (state is ProductsCubitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product added successfully')));
          Navigator.of(context).pop();
        }
      }, builder: (context, state) {
        return Stack(
          children: [
            //Add product form
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //product image picker and show
                        _buildImagePicker(),
                        SizedBox(height: 20),
                        //product name field
                        _buildNameField(),
                        SizedBox(height: 20),
                        //product description field
                        _buildDescriptionField(),
                        SizedBox(height: 20),
                        //product price field
                        _buildPriceField(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _confirmAddProduct,
                          child: Text('Add Product'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            //Loading indicator
            if (state is ProductsCubitLoading)
              Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black38,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        );
      }),
    );
  }

  AlertDialog _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm product details'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Name: $_name'),
          Text('Description: $_description'),
          Text('Price: \$ $_price'),
          Text(
              'Image Size: ${(_imageFile!.readAsBytesSync().lengthInBytes / 1024).floor()}KB'),
          Text(
              'Compressed Image Size: ${(_compressedImageFile!.readAsBytesSync().lengthInBytes / 1024).floor()}KB')
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            _addProduct();
            Navigator.of(context).pop();
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }

  GestureDetector _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 100,
        backgroundImage: _imageFile != null
            ? FileImage(_imageFile!)
            : AssetImage(
                'assets/blank.jpg',
              ) as ImageProvider,
      ),
    );
  }

  TextFormField _buildPriceField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.numberWithOptions(signed: true),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSaved: (value) {
        _price = value?.trim();
      },
      validator: (value) {
        if (value == null || value.isEmpty)
          return 'Enter a price';
        else
          return null;
      },
      decoration: InputDecoration(labelText: 'Price', prefixText: '\$'),
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      maxLines: 3,
      onSaved: (value) {
        _description = value?.trim();
      },
      validator: (value) {
        if (value == null)
          return 'Enter some description';
        else if (value.length < 3)
          return 'Desciption too short';
        else
          return null;
      },
      decoration: InputDecoration(labelText: 'Description'),
    );
  }

  TextFormField _buildNameField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      onSaved: (value) {
        _name = value?.trim();
      },
      validator: (value) {
        if (value == null)
          return 'Enter a name';
        else if (value.length < 3)
          return 'Name too short';
        else
          return null;
      },
      decoration: InputDecoration(labelText: 'Name'),
    );
  }
}
