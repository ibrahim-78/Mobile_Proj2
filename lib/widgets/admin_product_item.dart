import 'package:flutter/material.dart';
import 'package:project2/models/product.dart';
import 'package:project2/screens/admin_product_details_screen.dart';
import 'package:http/http.dart' as http;

class AdminProductItem extends StatelessWidget {
  final Product product;
  final double screenWidth;
  final VoidCallback? onTap;

  AdminProductItem({required this.product, required this.screenWidth, this.onTap});

  Future<void> deleteProduct(String id) async {
    final response = await http.post(
      Uri.parse('https://ibrahimandhasan.000webhostapp.com/deleteproduct.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'id': id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double discountedPrice = product.price;

    if (product.price > 100) {
      discountedPrice *= 0.8;
    }

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminProductDetailsScreen(product: product, screenWidth: screenWidth),
            ),
          );
        }
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            if (product.id != -1)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: product.id != -1 ? Colors.black.withOpacity(0.7) : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.id != -1)
                      Row(
                        children: [
                          Text(
                            'ID: ${product.id}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 30.0),
                        ],
                      ),
                    if (product.id != -1) SizedBox(height: 4.0),
                    if (product.id != -1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: product.price > 100 ? Colors.red : Colors.green,
                              decoration:
                              product.price > 100 ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          if (product.price > 100)
                            Text(
                              '\$${discountedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    if (product.id == -1)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 50, color: Colors.blue),
                            Text('Add Product', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                            SizedBox(height: 65.0),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (product.id != -1)
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.black54,
                  onPressed: () {
                    _showDeleteProductDialog(context, product.id.toString());
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteProduct(id);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No', style: TextStyle(
                color: Colors.blueGrey,
              )),
            ),
          ],
        );
      },
    );
  }
}