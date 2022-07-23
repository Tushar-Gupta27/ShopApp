import 'dart:math';

import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import '../models/http_exception.dart';
import "../providers/auth.dart";

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
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
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(
                          -10.0,
                          -15.0,
                        ),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade600,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 2,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'MyShop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

//AUTH CARD WIDGET

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _showPass = false;
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController? _controller;
  Animation<Offset>? _slideAnim;
  Animation<double>? _opAnim;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0.0, -1), end: const Offset(0.0, 0.0))
            .animate(CurvedAnimation(
                parent: _controller as Animation<double>,
                curve: Curves.linear));
    // _heightAnim?.addListener(() => setState(() {}));
    _opAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller as Animation<double>, curve: Curves.ease));

    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    // _heightAnim?.removeListener(() => setState(() {}));
    super.dispose();
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            'An error occured',
          ),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay'),
            )
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate();
    if (!(isValid as bool)) {
      // Invalid!
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
            _authData['email'] as String, _authData['password'] as String);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'] as String, _authData['password'] as String);
      }
    } on HttpException catch (err) {
      var errmsg = 'Something went Wrong, Try Again Later!';
      if (err.toString().contains('EMAIL_EXISTS')) {
        errmsg = 'A user already exists';
      } else if (err.toString().contains('INVALID_PASSWORD')) {
        errmsg = 'Wrong Password';
      } else if (err.toString().contains('EMAIL_NOT_FOUND')) {
        errmsg = 'Email not found, Try signing up';
      }

      _showErrorDialog(errmsg);
    } catch (e) {
      var errmsg = 'Something went Wrong, Try Again Later!';
      _showErrorDialog(errmsg);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller?.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller?.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 300 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if ((value?.isEmpty as bool) ||
                        !(value?.contains('@') as bool)) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value as String;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPass = !_showPass;
                        });
                      },
                      icon: Icon(
                          _showPass ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  obscureText: !_showPass,
                  controller: _passwordController,
                  validator: (value) {
                    if ((value?.isEmpty as bool) ||
                        ((value?.length as int) < 5)) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value as String;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 50 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 100 : 0),
                  child: FadeTransition(
                    opacity: _opAnim as Animation<double>,
                    child: SlideTransition(
                      position: _slideAnim as Animation<Offset>,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _showPass = !_showPass;
                              });
                            },
                            icon: Icon(_showPass
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ),
                        obscureText: !_showPass,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match!';
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      primary: Theme.of(context).primaryColor,
                      onPrimary:
                          Theme.of(context).primaryTextTheme.button?.color,
                    ),
                    onPressed: _submit,
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  ),
                TextButton(
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 4),
                    primary: Theme.of(context).primaryColor,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: _switchAuthMode,
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
