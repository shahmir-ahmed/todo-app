import 'package:flutter/material.dart';
import 'package:todo_app/application/shared_prefs.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/presentation/views/auth/login/login_view.dart';
import 'package:todo_app/presentation/views/home/home_view.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool? _loggedIn;

  _checkTokenFromSharedPref() async {
    final token = await SharedPrefsHelper().getToken();
    // print('token: $token');
    if (token != null) {
      setState(() {
        _loggedIn = true;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkTokenFromSharedPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('shopId: $shopId');
    return _loggedIn == null
        ? Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(child: Text('Loading...')),
            ),
            backgroundColor: FrontendConfigs.whiteColor,
          )
        : _loggedIn!
            ? const HomeView()
            : const LoginView();
  }
}
