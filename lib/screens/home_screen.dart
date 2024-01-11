import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project2/models/product.dart';
import 'package:project2/widgets/product_item.dart';
import 'cart_screen.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:project2/models/cart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(
          Uri.parse('https://ibrahimandhasan.000webhostapp.com/getproducts.php'));

      if (response.statusCode == 200) {
        final jsonResponse = convert.json.decode(response.body);
        List<Product> fetchedProducts = (jsonResponse['result'] as List<
            dynamic>)
            .map((item) => Product.fromJson(item))
            .toList();

        if (mounted) {
          setState(() {
            products = fetchedProducts;
          });
        }
      } else {
        print('Failed to fetch products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to fetch products: $e');
    }
  }

  void _showSearchDialog() {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Products'),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(labelText: 'Enter product name'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _searchProducts(searchQuery);
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey,
              ),
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _searchProducts(String query) {
    List<Product> searchResults = products
        .where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      products = searchResults;
    });
  }

  void _resetProducts() {
    _fetchProducts();
  }

  void _handleLogout(BuildContext? context) {
    Cart cart = context!.read<Cart>();
    if (!cart.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext? context) {
          return AlertDialog(
            title: Text('Cart is not empty'),
            content: Text('Please Checkout before logging out.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context!);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pushReplacementNamed(context!, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sports Store'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueGrey.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'search',
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            tooltip: 'shopping cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductItem(
              product: products[index], screenWidth: screenWidth);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade700,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _resetProducts();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                ),
                child: Text('Reset Products'),
              ),
              IconButton(
                onPressed: () {
                  _handleLogout(context);
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }
}