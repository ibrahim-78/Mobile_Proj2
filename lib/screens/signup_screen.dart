import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final String baseUrl = 'https://ibrahimandhasan.000webhostapp.com';

  Future<void> signUp(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup.php'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = convert.json.decode(response.body);
        showErrorSnackBar('${responseBody['result']}');

        if (responseBody.containsKey('result')) {
          String result = responseBody['result'];

          if (result == 'User registered successfully') {
          } else {
            print('Error: $result');
            showErrorDialog(result);
          }
        } else {
          print('Unexpected response format');
        }
      } else {
        print('Failed to sign up. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to sign up: $e');
    }
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            SizedBox(height: 20.0),
            _buildTextField(usernameController, 'Username', Icons.person),
            SizedBox(height: 20.0),
            _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
            SizedBox(height: 20.0),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.network(
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaF_CKeqg8tGqcVSCNStw9JBVfpM87yuB9pQ&usqp=CAU',
      height: 100.0,
      width: 100.0,
      fit: BoxFit.contain,
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.deepPurpleAccent),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepPurpleAccent, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: () async {
        String username = usernameController.text;
        String password = passwordController.text;

        if (username.isEmpty || password.isEmpty) {
          _showEmptyFieldsDialog();
        } else {
          await signUp(username, password);
          Navigator.of(context).pop();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurpleAccent,
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        'Sign Up',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }

  void _showEmptyFieldsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Empty Fields'),
          content: Text('Please fill in all fields before signing up.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }
}