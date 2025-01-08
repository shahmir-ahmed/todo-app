import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/application/shared_prefs_helper.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/services/user.dart';
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
      // get user profile
      await UserServices().getProfile(token).then((val){
        // print('val: ${val.toJson()}');
        if(val!=null){
          Provider.of<UserProvider>(context, listen: false).saveUser(val);
          setState(() {
            _loggedIn = true;
          });
        }
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
            body: Container(
              color: FrontendConfigs.kAppPrimaryColor,
              height: MediaQuery.of(context).size.height,
              child: const Center(child: //Text('Loading app...')
              SpinKitDoubleBounce(
                color: Colors.white,
                size: 50.0,
              )
              ),
            ),
            backgroundColor: FrontendConfigs.whiteColor,
          )
        : _loggedIn!
            ? const HomeView()
            : const LoginView();
  }
}
