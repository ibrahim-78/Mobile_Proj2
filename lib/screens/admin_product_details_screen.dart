import 'package:flutter/material.dart';
import 'package:project2/models/product.dart';
import 'package:http/http.dart' as http;
import 'admin_home_screen.dart';

class AdminProductDetailsScreen extends StatefulWidget {
  final Product product;
  final double screenWidth;

  AdminProductDetailsScreen({required this.product, required this.screenWidth});

  @override
  _AdminProductDetailsScreenState createState() => _AdminProductDetailsScreenState();
}

class _AdminProductDetailsScreenState extends State<AdminProductDetailsScreen> {
  String selectedSize = 'Small';
  String selectedColor = 'White';
  int _selectedQuantity = 1;
  double screenWidth = 0.0;

  final TextEditingController updateNameController = TextEditingController();
  final TextEditingController updateImageUrlController = TextEditingController();
  final TextEditingController updatePriceController = TextEditingController();
  final TextEditingController updateDescriptionController = TextEditingController();
  final TextEditingController selectedProductIdController = TextEditingController();

  Future<void> updateProduct(String id, String name, String imageUrl, String price, String description) async {
    final response = await http.post(
      Uri.parse('https://ibrahimandhasan.000webhostapp.com/updateproduct.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'price': price,
        'description': description,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double discountedPrice = widget.product.price;

    if (widget.product.price > 100) {
      discountedPrice *= 0.8;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildAppBar(context),
          _buildProductImage(),
          _buildProductInformation(discountedPrice),
          _buildVariationOptions(),
          _buildQuantitySelection(),
          _buildUpdateButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            tooltip: 'back',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product_image_${widget.product.id}',
      child: Container(
        height: screenWidth > 600 ? 300 : 200,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
          child: Image.network(
            widget.product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInformation(double discountedPrice) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: TextStyle(
              fontSize: screenWidth > 600 ? 24.0 : 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            '\$${discountedPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: screenWidth > 600 ? 20.0 : 18.0,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Description:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            widget.product.description,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildVariationOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVariationOption('Size', ['Small', 'Medium', 'Large']),
          SizedBox(height: 8.0),
          _buildVariationOption('Color', ['White', 'Black', 'Red']),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildVariationOption(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            return ChoiceChip(
              label: Text(
                option,
                style: TextStyle(
                  color: selectedSize == option || selectedColor == option ? Colors.white : Colors.black,
                ),
              ),
              selected: title == 'Size'
                  ? selectedSize == option
                  : title == 'Color'
                  ? selectedColor == option
                  : false,
              onSelected: (selected) {
                setState(() {
                  if (title == 'Size') {
                    selectedSize = option;
                  } else if (title == 'Color') {
                    selectedColor = option;
                  }
                });
              },
              backgroundColor: Colors.grey.withOpacity(0.2),
              selectedColor: Colors.blueGrey,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantitySelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Text('Quantity: '),
          DropdownButton<int>(
            value: _selectedQuantity,
            onChanged: (value) {
              setState(() {
                _selectedQuantity = value!;
              });
            },
            items: List.generate(10, (index) => index + 1)
                .map((quantity) => DropdownMenuItem<int>(
              value: quantity,
              child: Text(quantity.toString()),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          _showUpdateProductDialog();
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Text('Update Product'),
      ),
    );
  }

  void _showUpdateProductDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: Column(
            children: [
              TextField(
                controller: selectedProductIdController,
                decoration: InputDecoration(labelText: 'Product ID'),
              ),
              TextField(
                controller: updateNameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: updateImageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
              ),
              TextField(
                controller: updatePriceController,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: updateDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_validateUpdateFields()) {
                  _performUpdate();
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

  bool _validateUpdateFields() {
    if (selectedProductIdController.text.isEmpty || updateNameController.text.isEmpty || updateImageUrlController.text.isEmpty || updatePriceController.text.isEmpty || updateDescriptionController.text.isEmpty) {
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

  void _performUpdate() {
    updateProduct(selectedProductIdController.text, updateNameController.text, updateImageUrlController.text, updatePriceController.text, updateDescriptionController.text,);

    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AdminHomeScreen()),
    );
  }

  bool validateOptions() {
    return selectedSize.isNotEmpty && selectedColor.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    screenWidth = widget.screenWidth;
  }
}