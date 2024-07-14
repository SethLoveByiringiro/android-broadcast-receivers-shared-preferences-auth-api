import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:twitter_login/twitter_login.dart';

import 'auth_service.dart';
import 'calculator.dart';
import 'firebase_options.dart';
import 'signin.dart';
import 'signup.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => AuthService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late Battery _battery;
  late StreamSubscription<BatteryState> _batterySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _battery = Battery();
    _batterySubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (state == BatteryState.full) {
        Fluttertoast.showToast(msg: "Battery charged to 100%!");
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _batterySubscription.cancel();
    super.dispose();
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    String message;
    if (result == ConnectivityResult.none) {
      message = 'No Internet Connection';
    } else {
      message = 'Internet Connection Available';
    }
    Fluttertoast.showToast(msg: message);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId:
            '604532191314-4ta06alm211ha69s77fjhdp5m4htigu2.apps.googleusercontent.com',
      ).signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Fluttertoast.showToast(msg: "Signed in with Google");
    } catch (e) {
      print("Google sign-in error: $e");
      Fluttertoast.showToast(msg: "Failed to sign in with Google");
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        await FirebaseAuth.instance.signInWithCredential(credential);
        Fluttertoast.showToast(msg: "Signed in with Facebook");
      } else {
        Fluttertoast.showToast(msg: "Facebook sign-in cancelled");
      }
    } catch (e) {
      print("Facebook sign-in error: $e");
      Fluttertoast.showToast(msg: "Failed to sign in with Facebook");
    }
  }

  Future<void> signInWithTwitter() async {
    final twitterLogin = TwitterLogin(
      apiKey: 'YOUR_TWITTER_API_KEY',
      apiSecretKey: 'YOUR_TWITTER_API_SECRET_KEY',
      redirectURI: 'YOUR_TWITTER_REDIRECT_URI',
    );
    try {
      final authResult = await twitterLogin.login();
      switch (authResult.status) {
        case TwitterLoginStatus.loggedIn:
          final OAuthCredential twitterAuthCredential =
              TwitterAuthProvider.credential(
            accessToken: authResult.authToken!,
            secret: authResult.authTokenSecret!,
          );
          await FirebaseAuth.instance
              .signInWithCredential(twitterAuthCredential);
          Fluttertoast.showToast(msg: "Signed in with Twitter");
          break;
        case TwitterLoginStatus.cancelledByUser:
          Fluttertoast.showToast(msg: "Twitter sign-in cancelled");
          break;
        case TwitterLoginStatus.error:
          Fluttertoast.showToast(msg: "Twitter sign-in error");
          break;
        default:
          Fluttertoast.showToast(msg: "Unexpected Twitter sign-in status");
      }
    } catch (e) {
      print("Twitter sign-in error: $e");
      Fluttertoast.showToast(msg: "Failed to sign in with Twitter");
    }
  }

  Widget _buildSocialMediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.google, size: 24),
          onPressed: signInWithGoogle,
        ),
        SizedBox(width: 20),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebook, size: 24),
          onPressed: signInWithFacebook,
        ),
        SizedBox(width: 20),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.twitter, size: 24),
          onPressed: signInWithTwitter,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_selectedIndex) {
      case 0:
        currentPage = Column(
          children: [
            Expanded(child: SignIn()),
            _buildSocialMediaButtons(),
            SizedBox(height: 20),
          ],
        );
        break;
      case 1:
        currentPage = SignUp();
        break;
      case 2:
        currentPage = Calculator();
        break;
      default:
        currentPage = SignIn();
    }

    bool isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter App'),
        backgroundColor: Colors.black,
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text('Sign In'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.app_registration),
              title: Text('Sign Up'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
          ],
        ),
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Sign In',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Sign Up',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
