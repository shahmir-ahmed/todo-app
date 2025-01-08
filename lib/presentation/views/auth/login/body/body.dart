import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:flutter/material.dart';
// TODO: add flutter_svg package
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/application/navigation_helper.dart';
import 'package:todo_app/application/shared_prefs_helper.dart';
import 'package:todo_app/application/user_provider.dart';
import 'package:todo_app/configurations/frontend_configs.dart';
import 'package:todo_app/infrastructure/models/user.dart';
import 'package:todo_app/infrastructure/services/auth.dart';
import 'package:todo_app/infrastructure/services/user.dart';
import 'package:todo_app/presentation/elements/app_button.dart';
import 'package:todo_app/presentation/elements/custom_appbar.dart';
import 'package:todo_app/presentation/elements/custom_text_form_field.dart';
import 'package:todo_app/presentation/elements/loading_alert_dialog.dart';
import 'package:todo_app/presentation/elements/no_account_already_account_text.dart';
import 'package:todo_app/presentation/views/auth/register/register_view.dart';
import 'package:todo_app/presentation/views/home/home_view.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  bool isLoggingIn = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool showPassword = false;

  toggleIsLoggingIn() {
    setState(() {
      isLoggingIn = !isLoggingIn;
    });
  }

  void _loginUser() async {
    // Future.delayed(const Duration(seconds: 3), (){
    //   toggleIsLoggingIn();
    // });
    final user = UserModel(
        email: emailController.text.trim(),
        password: passwordController.text.trim());

    final loginResult = await AuthService().loginUser(user);

    // toggleIsLoggingIn();
    NavigationHelper.popScreen(context);

    if (loginResult == null) {
      floatingSnackBar(
          message: "An unexpected error has occurred. Please try again later.",
          context: context);
    } else if (loginResult == "error") {
      floatingSnackBar(
          message:
              // "Error occurred while logging in: ${result.toString().substring(5, result.toString().length)}",
              "Invalid email or password.",
          context: context);
    } else {
      // toggleIsLoggingIn();
      showLoadingAlertDialog(context, message: 'Logging in...');

      String token = loginResult;

      final profileResult = await UserServices().getProfile(token);

      // print('profileResult: ${profileResult.toJson()}');

      if (profileResult != null) {
        // String token = result.toString().substring(7, result.toString().length);
        // String token = result;

        // print('token: $token');

        final tokenSaveResult = await SharedPrefsHelper().saveToken(token);

        // print('result2: $result2');

        // toggleIsLoggingIn();
        NavigationHelper.popScreen(context);

        if (tokenSaveResult == 'success') {
          Provider.of<UserProvider>(context, listen: false)
              .saveUser(profileResult);
          NavigationHelper.popScreen(context);
          NavigationHelper.pushScreen(context, const HomeView());
          floatingSnackBar(
              message: "Logged in successfully.", context: context);
        } else {
          floatingSnackBar(message: "Error logging in.", context: context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      color: FrontendConfigs.kAppPrimaryColor.withOpacity(0.3),
      progressIndicator: const CircularProgressIndicator(
        color: FrontendConfigs.kAppPrimaryColor,
      ),
      isLoading: isLoggingIn,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(title: 'Login'),
        body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login with your email and password  ",
                        // "\nor continue with social media",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Form(
                    child: Column(
                      children: [
                        CustomTextFormField(
                          controller: emailController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          hintText: "Enter your email",
                          labelText: "Email",
                          suffix: SvgPicture.string(
                            FrontendConfigs.mailIcon,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: CustomTextFormField(
                            isPassword: true,
                            controller: passwordController,
                            obscureText: !showPassword,
                            onSuffixTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            suffix: Icon(
                                showPassword ? Icons.lock_open : Icons.lock),
                            hintText: "Enter your password",
                            labelText: "Password",
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: () {
                            // email password login
                            if (emailController.text.trim().isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter email.",
                                  context: context);
                              return;
                            } else if (passwordController.text.trim().isEmpty) {
                              floatingSnackBar(
                                  message: "Please enter password.",
                                  context: context);
                              return;
                            }
                            FocusScope.of(context).requestFocus(FocusNode());
                            // toggleIsLoggingIn();
                            showLoadingAlertDialog(context, message: 'Logging in...');
                            _loginUser();
                          },
                          child: const Text("Continue"),
                        )
                      ],
                    ),
                  ),
                  /*
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
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
                  NoAccountAlreadyAccountText(
                      primaryText: "Don’t have an account? ",
                      redirectText: 'Register',
                      onTap: () {
                        NavigationHelper.pushScreen(
                            context, const RegisterView());
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
