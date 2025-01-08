import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper{

  Future saveToken(String token) async{
    try {
      final instance = await SharedPreferences.getInstance();
      // final cleared = await instance.clear();
      // print('cleared: $cleared');
      final set = await instance.setString('TOKEN', token);
      // print('set: $set');
      return 'success';
    }catch(e){
      print('Err in saveToken: $e');
      return 'error';
    }
  }

  Future getToken() async{
    try {
      final instance = await SharedPreferences.getInstance();
      final token = instance.getString('TOKEN');
      return token;
    }
    catch(e){
      print('Err in getToken: $e');
      return 'error';
    }
  }

  Future clearPrefs() async{
    try {
      final instance = await SharedPreferences.getInstance();
      final cleared = await instance.clear();
      return cleared ? 'success' : 'error';
    }
    catch(e){
      print('Err in getToken: $e');
      return null;
    }
  }
}