import 'package:flutter/material.dart';
import 'package:project2/models/product.dart';
import 'package:project2/widgets/admin_product_item.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
//product_details
class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  List<Product> products = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> addProduct(String name, String imageUrl, String price, String description) async {
    final response = await http.post(
      Uri.parse('https://ibrahimandhasan.000webhostapp.com/addproduct.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'description': description,
      },
    );
    _resetProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('https://ibrahimandhasan.000webhostapp.com/getproducts.php'));

      if (response.statusCode == 200) {
        final jsonResponse = convert.json.decode(response.body);
        List<Product> fetchedProducts =
        (jsonResponse['result'] as List<dynamic>).map((item) => Product.fromJson(item)).toList();

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
    List<Product> searchResults = products.where((product) => product.name.toLowerCase().contains(query.toLowerCase())).toList();

    setState(() {
      products = searchResults;
    });
  }

  void _resetProducts() {
    _fetchProducts();
  }

  void _showAddProductDialog() {
    nameController.text = '';
    imageUrlController.text = '';
    priceController.text = '';
    descriptionController.text = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_validateFields()) {
                  addProduct(nameController.text, imageUrlController.text, priceController.text, descriptionController.text,);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey,
              ),
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(
                color: Colors.blueGrey,
              )
              ),
            ),
          ],
        );
      },
    );
  }

  bool _validateFields() {
    if (nameController.text.isEmpty || imageUrlController.text.isEmpty || priceController.text.isEmpty || descriptionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Please fill all the fields.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sports Store (Admin)'),
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
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == products.length) {
            return AdminProductItem(
              product: Product(id: -1, name: "", imageUrl: "", price: 0, description: ""),
              screenWidth: screenWidth,
              onTap: () {
                _showAddProductDialog();
              },
            );
          } else {
            return AdminProductItem(
              product: products[index],
              screenWidth: screenWidth,
            );
          }
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
                  Navigator.pushReplacementNamed(context, '/login');
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