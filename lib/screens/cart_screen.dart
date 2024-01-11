import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project2/models/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        backgroundColor: Colors.blueGrey.shade700,
      ),
      body: cart.items.isEmpty
          ? Center(
        child: Text('Your shopping cart is empty.'),
      )
          : ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              title: Text(item.productName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${item.productQuantity}'),
                  Text('Total: \$${(item.productQuantity * item.productPrice).toStringAsFixed(2)}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _handleDelete(context, cart, index);
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: cart.items.isNotEmpty
          ? BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: \$${cart.calculateTotal().toStringAsFixed(2)}'),
              ElevatedButton(
                onPressed: () {
                  _handleCheckout(context, cart);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey,
                ),
                child: Text('Checkout'),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }

  void _handleDelete(BuildContext context, Cart cart, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete ${cart.items[index].productName}?'),
          actions: [
            TextButton(
              onPressed: () {
                cart.removeItem(index);
                Navigator.pop(context);
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

  void _handleCheckout(BuildContext context, Cart cart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Checkout Confirmation'),
          content: Text('Total amount: \$${cart.calculateTotal().toStringAsFixed(2)}'),
          actions: [
            TextButton(
              onPressed: () {
                cart.clearCart();
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(
                color: Colors.blueGrey,
              )),
            ),
          ],
        );
      },
    );
  }
}