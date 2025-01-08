import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/infrastructure/models/user.dart';
import 'package:todo_app/infrastructure/services/user.dart';
import 'package:todo_app/presentation/elements/app_button.dart';
import 'package:todo_app/presentation/elements/custom_text_form_field.dart';
import 'package:todo_app/presentation/elements/loading_alert_dialog.dart';

import '../../../../application/user_provider.dart';
import '../../../../configurations/frontend_configs.dart';

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    final user = Provider.of<UserProvider>(context, listen: false).getUser;
    if (user != null) {
      nameController.text = user.name.toString();
      emailController.text = user.email.toString();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // print('userProvider.loading: ${userProvider.loading}');

    /*
    if (userProvider.getUser != null) {
      // print(
      //     'userProvider.getUser!: ${userProvider.getUser!.toJson().toString()}');
      nameController.text = userProvider.getUser!.name.toString();
      emailController.text = userProvider.getUser!.email.toString();
    }
    */

    return Scaffold(
      backgroundColor: FrontendConfigs.whiteColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: FrontendConfigs.whiteColor,
      ),
      body: LoadingOverlay(
        isLoading: isLoading,
        progressIndicator: const CircularProgressIndicator(
          color: FrontendConfigs.kAppPrimaryColor,
        ),
        color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // userProvider.loading
              //     ? const Center(child: CircularProgressIndicator())
              userProvider.getUser == null
                  ? const Center(child: Text('Error loading profile.'))
                  // : userProvider.getUser!.name!.isEmpty
                  //     ? const Center(
                  //         child: CircularProgressIndicator(
                  //         color: FrontendConfigs.kAppPrimaryColor,
                  //       ))
                  :
                  /*Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Name: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${userProvider.getUser!.name}'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('${userProvider.getUser!.email}'),
                              ],
                            ),
                            */
                  // Text(
                  //     'Name: ${userProvider.getUser!.name}, Email: ${userProvider.getUser!.email}'),

                  CustomTextFormField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                          hintText: "Enter your name",
                          labelText: "Name",
                    ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                    hintText: "Enter your email",
                    labelText: "Email",
              ),

              const SizedBox(height: 30),
              AppButton(
                onPressed: () {
                  // email password login
                  if (nameController.text.trim().isEmpty) {
                    floatingSnackBar(
                        message: "Please enter name.", context: context);
                    return;
                  } else if (emailController.text.trim().isEmpty) {
                    floatingSnackBar(
                        message: "Please enter email.", context: context);
                    return;
                  }
                  FocusScope.of(context).requestFocus(FocusNode());
                  // toggleIsLoading();
                  showLoadingAlertDialog(context, message: 'Updating profile...');
                  final user = UserModel(name: nameController.text.trim(), email: emailController.text.trim(), token: Provider.of<UserProvider>(context, listen: false).getUser!.token!);
                  _updateProfile(user);
                },
                child: const Text("Update"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void toggleIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void _updateProfile(UserModel user) async {
    await UserServices().updateProfile(user).then((val) {
      // toggleIsLoading();
      Navigator.pop(context);

      if (val != null) {
        Provider.of<UserProvider>(context, listen: false).saveUser(user);
        Navigator.pop(context);
        floatingSnackBar(
            message: 'Profile updated successfully', context: context);
      } else {
        floatingSnackBar(
            message: 'Error updating profile. Please try again later.',
            context: context);
      }
    });
  }
}
