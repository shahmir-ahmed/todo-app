import 'package:flutter/material.dart';
// TODO: add flutter_svg package
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:todo_app/application/navigation_helper.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/models/user.dart';
import 'package:todo_app/infrastructure/services/auth.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:todo_app/presentation/elements/app_button.dart';
import 'package:todo_app/presentation/elements/custom_appbar.dart';
import 'package:todo_app/presentation/elements/custom_text_form_field.dart';
import 'package:todo_app/presentation/elements/loading_alert_dialog.dart';

import '../../../../elements/no_account_already_account_text.dart';

class RegisterViewBody extends StatefulWidget {
  const RegisterViewBody({super.key});

  @override
  State<RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<RegisterViewBody> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isRegistering = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  toggleIsRegistering() {
    setState(() {
      isRegistering = !isRegistering;
    });
  }

  _registerUser(context) async {
    final user = UserModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim());

    final result = await AuthService().registerUser(user);

    // toggleIsRegistering();
    NavigationHelper.popScreen(context);

    if (result == null) {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    } else if (result.startsWith("error")) {
      floatingSnackBar(
          message:
              "Error occurred while registering: ${result.toString().substring(5, result.toString().length)}",
          context: context);
    } else if (result.startsWith("success")) {
      NavigationHelper.popScreen(context);
      floatingSnackBar(
          message:
              "Registered successfully. Please login using your credentials.",
          context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.3),
      progressIndicator: const CircularProgressIndicator(
        color: FrontendConfigs.kAppPrimaryColor,
      ),
      isLoading: isRegistering,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(title: 'Register'),
        body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Register Account",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Complete your details ",
                        // "or continue \nwith social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Form(
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          hintText: "Enter your name",
                          labelText: "Name",
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: CustomTextFormField(
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            textInputAction: TextInputAction.next,
                            hintText: "Enter your email",
                            labelText: "Email",
                            suffix: SvgPicture.string(
                              FrontendConfigs.mailIcon,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: CustomTextFormField(
                            controller: passwordController,
                            obscureText: !showPassword,
                            textInputAction: TextInputAction.next,
                            hintText: "Enter your password",
                            labelText: "Password",
                            isPassword: true,
                            onSuffixTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            suffix: Icon(
                                showPassword ? Icons.lock_open : Icons.lock),
                          ),
                        ),
                        CustomTextFormField(
                          controller: confirmPasswordController,
                          obscureText: !showConfirmPassword,
                          hintText: "Enter your password",
                          labelText: "Re-enter your password",
                          isPassword: true,
                          onSuffixTap: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                          suffix:
                              Icon(showConfirmPassword ? Icons.lock_open : Icons.lock),
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter name.",
                                  context: context);
                              return;
                            } else if (emailController.text.trim().isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter email.",
                                  context: context);
                              return;
                            } else if (passwordController.text.trim().isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter password.",
                                  context: context);
                              return;
                            } else if (confirmPasswordController.text
                                .trim()
                                .isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter password again.",
                                  context: context);
                              return;
                            }
                            // toggleIsRegistering();
                            showLoadingAlertDialog(context, message: 'Registering...');
                            _registerUser(context);
                          },
                          child: const Text("Continue"),
                        )
                      ],
                    ),
                  ),
                  /*
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocalCard(
                        icon: SvgPicture.string(googleIcon),
                        press: () {},
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SocalCard(
                          icon: SvgPicture.string(facebookIcon),
                          press: () {},
                        ),
                      ),
                      SocalCard(
                        icon: SvgPicture.string(twitterIcon),
                        press: () {},
                      ),
                    ],
                  ),
                   */
                  const SizedBox(height: 16),

                  const Text(
                    "By continuing you confirm that you agree \nwith our Terms and Conditions",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // NoAccountAlreadyAccountText(
                  //     primaryText: "Already have an account? ",
                  //     redirectText: 'Login',
                  //     onTap: () {
                  //       NavigationHelper.popScreen(context);
                  //     })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
