import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/application/navigation_helper.dart';
import 'package:todo_app/application/shared_prefs_helper.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/presentation/elements/loading_alert_dialog.dart';
import 'package:todo_app/presentation/views/search_by_dates/search_by_dates_view.dart';
import 'package:todo_app/presentation/views/todos/todos_view.dart';

import '../../application/user_provider.dart';
import '../views/auth/login/login_view.dart';
import '../views/profile/profile_view.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String token = '';

  bool isLoggingOut = false;

  toggleIsLoggingOut() {
    setState(() {
      isLoggingOut = !isLoggingOut;
    });
  }

  _logoutUser() async {
    final result = await SharedPrefsHelper().clearPrefs();
    // print('result: $result');
    toggleIsLoggingOut();
    if (result != null) {
      if (result == 'success') {
        Provider.of<UserProvider>(context, listen: false).saveUser(null);
        NavigationHelper.popScreen(context);
        NavigationHelper.pushScreen(context, const LoginView());
        floatingSnackBar(message: 'Logged out.', context: context);
      } else {
        floatingSnackBar(message: 'Error logging out.', context: context);
      }
    } else {
      floatingSnackBar(message: 'Error logging out.', context: context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    SharedPrefsHelper().getToken().then((val) {
      setState(() {
        token = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const LinearBorder(side: BorderSide.none),
      width: 280.0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              MyHeaderDrawer(),
              token.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : MyDrawerList(),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer List for drawer menu
  Widget MyDrawerList() {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.only(
        top: 5,
      ),
      child: Column(
        // shows the list of menu drawer
        children: [
          menuItem("Search todo by dates", Icons.search),
          menuItem("Profile", Icons.person_outlined),
          menuItem("Completed", Icons.check_circle_outline_rounded),
          menuItem("Incompleted", Icons.pending_outlined),
          // isLoggingOut ? const SizedBox() : menuItem("Logout", Icons.logout_outlined),
          menuItem("Logout", Icons.logout_outlined),
        ],
      ),
    );
  }

// function to return a list item for drawer menu
  Widget menuItem(String title, IconData icon) {
    return Material(
      // color: Colors.transparent,
      color: FrontendConfigs.whiteColor,
      surfaceTintColor: FrontendConfigs.whiteColor,
      child: InkWell(
        onTap: () async {
          // close the drawer menu
          Navigator.pop(context);

          if (title == "Search todo by dates") {
            NavigationHelper.pushScreen(
              context,
              const SearchByDatesView(),
            );
          }
          if (title == "Profile") {
            NavigationHelper.pushScreen(
              context,
              const ProfileView(),
            );
          } else if (title == "Completed") {
            NavigationHelper.pushScreen(context, TodosView(type: 'Completed'));
          } else if (title == "Incompleted") {
            NavigationHelper.pushScreen(
                context, TodosView(type: 'Incompleted'));
          }
          else if (title == "Logout") {
            // toggleIsLoggingOut();
            NavigationHelper.popScreen(context);
            showLoadingAlertDialog(context, message: 'Logging out...');
            _logoutUser();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
          child: Row(
            children: [
              Expanded(
                child: Icon(
                  icon,
                  size: 22,
                  color: Colors.black,
                  // color: title == "Logout"
                  //     ? FrontendConfigs.kAppRedColor
                  //     : FrontendConfigs.kAppTextColor,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  // color: title == "Logout"
                  //     ? FrontendConfigs.kAppRedColor
                  //     : FrontendConfigs.kAppTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Drawer Header i.e. Student Details
class MyHeaderDrawer extends StatefulWidget {
  MyHeaderDrawer({super.key});

  @override
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue[700],
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.only(top: 50.0, left: 20),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            height: 40,
            width: 40,
            child: Image.asset('assets/images/logo.jpg'),
          ),
          const Text(
            "Todo",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
