import 'package:flutter/material.dart';
import 'package:todo_app/configurations/frontend_configs.dart';

Future showLoadingAlertDialog(BuildContext context,
    {required String message}) async {
  var alert = AlertDialog(
    backgroundColor: FrontendConfigs.whiteColor,
    title: const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(child: CircularProgressIndicator(color: FrontendConfigs.kAppPrimaryColor,),)),
    content: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Adjusts height to fit content
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    message,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(onWillPop: () async => false, child: alert);
        // return alert;
      });
}
