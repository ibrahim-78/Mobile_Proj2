import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordFocus = FocusNode();
  FocusNode usernameFocus = FocusNode();
  bool isPasswordIncorrect = false;
  final String baseUrl = 'https://ibrahimandhasan.000webhostapp.com';

  Future<void> login(String username, String password) async {
    try {
      if (username.isEmpty && password.isEmpty) {
        showErrorDialog('Please enter Username and Password');
        return;
      }

      if (username == "admin") {
        await loginAdmin(username, password);
      } else {
        await loginUser(username, password);
      }
    } catch (e) {
      print('Failed to log in: $e');
      showErrorSnackBar('Failed to log in. Please try again.');
    }
  }

  Future<void> loginAdmin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin_login.php'),
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

        if (responseBody.containsKey('result')) {
          String result = responseBody['result'];

          if (result == 'Login successful') {
            showErrorSnackBar('$result');
            Navigator.pushReplacementNamed(context, '/admin');
          } else {
            setState(() {
              isPasswordIncorrect = true;
            });
            showErrorSnackBar('$result');
          }
        } else {
          print('Unexpected response format');
        }
      } else {
        print('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to log in: $e');
      showErrorSnackBar('Failed to log in. Please try again.');
    }
  }

  Future<void> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user_login.php'),
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

        if (responseBody.containsKey('result')) {
          String result = responseBody['result'];

          if (result == 'Login successful') {
            showErrorSnackBar('$result');
            await _storeLoggedInUser(username);
            Navigator.pushReplacementNamed(context, '/welcome');
          } else {
            setState(() {
              isPasswordIncorrect = true;
            });
            showErrorSnackBar('$result');
          }
        } else {
          print('Unexpected response format');
        }
      } else {
        print('Failed to log in. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to log in: $e');
      showErrorSnackBar('Failed to log in. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueAccent, Colors.deepPurpleAccent],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              _buildLoginForm(),
              _buildSignUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Image.network(
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaF_CKeqg8tGqcVSCNStw9JBVfpM87yuB9pQ&usqp=CAU',
        height: 100.0,
        width: 100.0,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          _buildTextField(usernameController, 'Username', Icons.person),
          SizedBox(height: 20.0),
          _buildTextField(passwordController, 'Password', Icons.lock, isPassword: true),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              String username = usernameController.text;
              String password = passwordController.text;
              setState(() {
                isPasswordIncorrect = false;
              });
              await login(username, password);
              if (isPasswordIncorrect) {
                FocusScope.of(context).requestFocus(passwordFocus);
                FocusScope.of(context).requestFocus(usernameFocus);
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
              'Login',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
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
        errorText: isPasswordIncorrect ? 'Incorrect $labelText' : null,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Text(
        'Don\'t have an account? Sign up here',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          decoration: TextDecoration.underline,
        ),
      ),
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
}

Future<void> _storeLoggedInUser(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('loggedInUser', username);
}