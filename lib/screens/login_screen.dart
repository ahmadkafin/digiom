import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../providers/auth.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF558B2F),
                  Color(0xFF558B2F),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 94.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: Image.asset('img/digiom_white.png'),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 94.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                      ),
                      child: const Text(
                        "Digio for Operation and Maintenance Dashboard",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: LoginCard(),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  LoginCard({Key? key}) : super(key: key);

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  Map<String, String> _authData = {'username': '', 'password': ''};
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;

  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error has Occured'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false).login(
        _authData['username'].toString(),
        _authData['password'].toString(),
      );
    } on HttpException catch (error) {
      var errorMessage = 'Autentication Failed';
      if (error.toString().contains(
          'Maaf username salah atau anda tidak berada di satuan kerja OMM')) {
        errorMessage =
            'Maaf username salah atau anda tidak berada di satuan kerja OMM';
      } else if (error.toString().contains(
          "Username / Password Salah atau anda tidak punya hak akses.")) {
        errorMessage =
            "Username / Password Salah atau anda tidak punya hak akses.";
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Terjadi gangguan pada server silakan coba lagi nanti';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 260,
        constraints: BoxConstraints(
          minHeight: 260,
        ),
        width: deviceSize.width * 0.9,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: Color(0xFF558B2F)),
                  cursorColor: Color(0xFF558B2F),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF558B2F)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF558B2F)),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(
                      color: Color(0xFF558B2F),
                    ),
                    icon: Icon(
                      Icons.person,
                      color: Color(0xFF558B2F),
                    ),
                    hintText: "Username",
                    hintStyle: TextStyle(color: Color(0xFF558B2F)),
                    fillColor: Color(0xFF558B2F),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Username Tidak boleh kosong';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['username'] = value.toString();
                  },
                ),
                TextFormField(
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: Color(0xFF558B2F)),
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF558B2F)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF558B2F)),
                    ),
                    labelStyle: TextStyle(
                      color: Color(0xFF558B2F),
                    ),
                    hintStyle: TextStyle(
                      color: Color(0xFF558B2F),
                    ),
                    labelText: 'Password',
                    icon: Icon(
                      Icons.lock,
                      color: Color(0xFF558B2F),
                    ),
                    focusColor: Color(0xFF558B2F),
                  ),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Password tidak boleh kosong";
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value.toString();
                  },
                ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text("Login"),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFF558B2F),
                      padding: EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 8.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
