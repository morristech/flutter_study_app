import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_study_app/components/return_bar.dart';
import 'package:flutter_study_app/config.dart';
import 'package:flutter_study_app/models/github_login.dart';
import 'package:flutter_study_app/service/authentication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

enum FormType {
  LOGIN,
  REGISTER,
}

class EmailFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? '邮箱不能为空' : null;
  }
}

class PasswordFieldValidator {
  static String validate(String value) {
    return value.isEmpty ? '密码不能为空' : null;
  }
}

/// login and register
class AccountScreen extends StatefulWidget {
//  final BaseAuth auth;
//  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() {
    return _AccountScreenState();
  }

//  AccountScreen(this.auth, this.onSignedIn);
}

class _AccountScreenState extends State<AccountScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//  static final TwitterLogin twitterLogin = new TwitterLogin(
//      consumerKey: AppConfig.twitterApiKey,
//      consumerSecret: AppConfig.twitterApiSecret
//  );

  String _email;
  String _password;
  FormType _formType = FormType.LOGIN;
  StreamSubscription _subs;

  String _errorMessage;

  bool _isLoading;

  String username = 'Your Name';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
//  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 验证和保存
  bool _validateAndSave() {
    final FormState state = formKey.currentState;
    if (state.validate()) {
      state.save();
      return true;
    }
    return false;
  }

  /// 跳到注册页
  void moveToRegister() {
    formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formType = FormType.REGISTER;
    });
  }

  /// 跳到登录页
  void moveToLogin() {
    formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formType = FormType.LOGIN;
    });
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content:
          new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                moveToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ReturnBar(''),
      body: Container(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: buildInputs() + buildSubmitButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    return <Widget>[
      TextFormField(
        key: Key('email'),
        decoration: InputDecoration(labelText: '邮箱'),
        validator: EmailFieldValidator.validate,
        onSaved: (String value) {
          _email = value;
        },
      ),
      TextFormField(
        key: Key('password'),
        decoration: InputDecoration(labelText: '密码'),
        validator: PasswordFieldValidator.validate,
        onSaved: (String value) {
          _password = value;
        },
      )
    ];
  }

  void onClickGitHubLoginButton() async {
    const String url = "https://github.com/login/oauth/authorize" +
        "?client_id=" + AppConfig.GITHUB_CLIENT_ID +
        "&scope=public_repo%20read:user%20user:email";

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      print("CANNOT LAUNCH THIS URL!");
    }
  }


//  void _loginTwitter() async {
//    final TwitterLoginResult result = await twitterLogin.authorize();
//    String newMessage;
//
//    switch (result.status) {
//      case TwitterLoginStatus.loggedIn:
//        newMessage = 'Logged in! username: ${result.session.username}';
//        break;
//      case TwitterLoginStatus.cancelledByUser:
//        newMessage = 'Login cancelled by user.';
//        break;
//      case TwitterLoginStatus.error:
//        newMessage = 'Login error: ${result.errorMessage}';
//        break;
//    }
//  }


//  Future<FirebaseUser> loginWithGitHub(String code) async {
//    //ACCESS TOKEN REQUEST
//    final response = await http.post(
//      "https://github.com/login/oauth/access_token",
//      headers: {
//        "Content-Type": "application/json",
//        "Accept": "application/json"
//      },
//      body: jsonEncode(GitHubLoginRequest(
//        clientId: AppConfig.GITHUB_CLIENT_ID,
//        clientSecret: AppConfig.GITHUB_CLIENT_SECRET,
//        code: code,
//      )),
//    );

//    GitHubLoginResponse loginResponse =
//    GitHubLoginResponse.fromJson(json.decode(response.body));
//
//    //FIREBASE STUFF
//    final AuthCredential credential = GithubAuthProvider.getCredential(
//      token: loginResponse.accessToken,
//    );
//
//    final AuthResult user =
//    await FirebaseAuth.instance.signInWithCredential(credential);
//    return user.user;
//  }

//  Future<FirebaseUser> _googleHandleSignIn() async {
//    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
//    final GoogleSignInAuthentication googleAuth =
//    await googleUser.authentication;
//
//    final AuthCredential credential = GoogleAuthProvider.getCredential(
//      accessToken: googleAuth.accessToken,
//      idToken: googleAuth.idToken,
//    );
//
//    final AuthResult result = await _auth.signInWithCredential(credential);
//    setState(() {
//      username = result.user.displayName;
//    });
//    return result.user;
//  }

  /// 验证和提交
//  Future<void> _validateAndSubmit() async {
//    setState(() {
//      _errorMessage = "";
//      _isLoading = true;
//    });
//    if (_validateAndSave()) {
//      String userId = "";
//      try {
//        if (_formType == FormType.LOGIN) {
//          userId = await widget.auth.signIn(_email, _password);
//          print('Signed in: $userId');
//        } else {
//          userId = await widget.auth.signUp(_email, _password);
//          widget.auth.sendEmailVerification();
//          _showVerifyEmailSentDialog();
//          print('注册');
//        }
//        setState(() {
//          _isLoading = false;
//        });
//
//        if (userId.length > 0 &&
//            userId != null &&
//            _formType == FormType.LOGIN) {
//          widget.onSignedIn();
//        }
//      } catch (e) {
//        print('Error: $e');
//      }
//    }
//  }

  @override
  void initState() {
    super.initState();
    _errorMessage = '';
    _isLoading = false;
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() async {
    _subs = getLinksStream().listen((String link) {
//      _checkDeepLink(link);
    }, cancelOnError: true);
  }

//  void _checkDeepLink(String link) {
//    if (link != null) {
//      String code = link.substring(link.indexOf(RegExp('code=')) + 5);
//      loginWithGitHub(code)
//          .then((firebaseUser) {
//        print("LOGGED IN AS: " + firebaseUser.displayName);
//      }).catchError((e) {
//        print("LOGIN ERROR: " + e.toString());
//      });
//    }
//  }

  @override
  void dispose() {
    super.dispose();
    if (_subs != null) {
      _subs.cancel();
      _subs = null;
    }
  }

  /// 构建提交按钮
  /// 登录注册
  List<Widget> buildSubmitButtons() {
    if (_formType == FormType.LOGIN) {
      return <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        RaisedButton(
          color: Colors.blue,
          key: Key('signIn'),
          child:
          Text('登录', style: TextStyle(fontSize: 20.0, color: Colors.white)),
//          onPressed: _validateAndSubmit,
        ),
        Padding(
          padding: EdgeInsets.only(top: 30),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            InkWell(
//              onTap: _loginTwitter,
              child: Icon(
                FontAwesomeIcons.twitter,
                size: 30,
              ),
            ),
            InkWell(
              onTap: onClickGitHubLoginButton,
              child: Icon(
                FontAwesomeIcons.github,
                size: 30,
              ),
            ),
            Icon(
              FontAwesomeIcons.weixin,
              size: 30,
            ),
            InkWell(
              child: Icon(
                FontAwesomeIcons.google,
                size: 30,
              ),
//              onTap: () =>
//                  _googleHandleSignIn()
//                      .then((FirebaseUser user) =>
//                      setState(() {
//                        username = user.displayName;
//                        print(username);
//                      }))
//                      .catchError((e) => print(e)),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 30),
        ),
        FlatButton(
          child: Text('创建一个账号', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToRegister,
        ),
      ];
    } else {
      return <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 10),
        ),
        RaisedButton(
          color: Colors.blue,
          child: Text('创建一个账号',
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: () {
            debugPrint('login');
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 0),
        ),
        FlatButton(
          child: Text('己有账号?去登录', style: TextStyle(fontSize: 20.0)),
          onPressed: moveToLogin,
        ),
      ];
    }
  }
}
