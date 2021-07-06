import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product_model.dart';
import '../blocs/products_cubit.dart';
import '../blocs/auth_cubit.dart';
import 'add_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  _UserProductsScreenState createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  List<ProductModel> _products = [];
  bool _isFetching = true;
  bool hasMore = false;
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _controller.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollControllerListener);
    _controller.dispose();
    super.dispose();
  }

  void _scrollControllerListener() {
    if (_controller.offset == _controller.position.maxScrollExtent &&
        !_isFetching &&
        hasMore) {
      setState(() {
        _isFetching = true;
        _fetchProducts(false);
      });
    }
  }

  void _fetchProducts([bool fromStart = true]) {
    context.read<ProductsCubit>().fetchProducts(
        context.read<AuthCubit>().state.user.id!,
        fromStart: fromStart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ProductsCubit, ProductsCubitStates>(
        listener: (context, state) {
          if (state is ProductsCubitFetched)
            setState(() {
              _isFetching = false;
              hasMore = state.products.length == 10;
              _products.addAll(state.products);
            });
          else if (state is ProductsCubitFailed)
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Somethng went wrong!')));
          else if (state is ProductsCubitFetching)
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fetching more products')));
        },
        child: RefreshIndicator(
          onRefresh: () async {
            _products = [];
            _fetchProducts();
          },
          child: ListView.builder(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _products.length + 1,
              itemBuilder: (ctx, index) {
                if (_products.isEmpty)
                  return Center(child: Text('Nothing to show'));
                else if (index == _products.length)
                  return Container(
                    height: 50,
                    child: hasMore
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : null,
                  );
                else
                  return ProductWidget(_products[index]);
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddProductScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget(this._product, {Key? key}) : super(key: key);

  final ProductModel _product;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Image.network(_product.image),
            ),
            SizedBox(width: 10),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 5),
                  Text(_product.description),
                  SizedBox(height: 5),
                  Text(
                    '\$ ${_product.price}',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
