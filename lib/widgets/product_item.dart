import 'package:flutter/material.dart';
import 'package:project2/models/product.dart';
import 'package:project2/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  final double screenWidth;

  ProductItem({required this.product, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    double discountedPrice = product.price;

    if (product.price > 100) {
      discountedPrice *= 0.8;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product, screenWidth: screenWidth),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
              child: Container(
                height: 150,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl,
                  width: screenWidth / 2 - 12.0,
                  height: 150,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.0),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}