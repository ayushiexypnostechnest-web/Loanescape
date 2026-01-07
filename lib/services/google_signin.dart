import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignin {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '192018092754-1099ftv3ss5sqtcfuhrbdlls0dvbqvvm.apps.googleusercontent.com', // WEB CLIENT ID
  );

  static Future<GoogleSignInAccount?> login() async {
    return await _googleSignIn.signIn();
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
  }

  static Future<void> disconnect() async {
    await _googleSignIn.disconnect();
  }
}
