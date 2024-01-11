import 'package:flutter/material.dart';
import 'package:project2/models/product.dart';
import 'package:provider/provider.dart';
import 'package:project2/models/cart.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final double screenWidth;

  ProductDetailsScreen({required this.product, required this.screenWidth});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = 'Small';
  String selectedColor = 'White';
  int _selectedQuantity = 1;
  double screenWidth = 0.0;

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
          _buildAddToCartButton(discountedPrice),
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

  Widget _buildAddToCartButton(double discountedPrice) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          if (validateOptions()) {
            if (widget.product.price > 100) {
              Provider.of<Cart>(context, listen: false).addToCart(
                productName: widget.product.name,
                productQuantity: _selectedQuantity,
                productPrice: discountedPrice,
              );
            } else {
              Provider.of<Cart>(context, listen: false).addToCart(
                productName: widget.product.name,
                productQuantity: _selectedQuantity,
                productPrice: widget.product.price,
              );
            }
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please select valid options before adding to the cart.'),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.green,
        ),
        child: Text('Add to Cart'),
      ),
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