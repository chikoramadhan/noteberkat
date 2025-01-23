import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/streams/front_stream.dart';

class FrontPageUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<FrontPageUI> with SingleTickerProviderStateMixin {
  late Animation<double> _blurAnimation;
  late AnimationController _blurController;

  final TextEditingController _loginEmailController =
      new TextEditingController();
  final TextEditingController _loginPasswordController =
      new TextEditingController();

  final List<FocusNode> _loginNode = [];

  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  int _state = -1;
  int _currentState = 0;
  int _progress = 0;

  bool _obsText = true;

  TextStyle _titleStyle = new TextStyle(
    color: Colors.white,
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    fontFamily: "Saira",
  );
  TextStyle _subtitleStyle = new TextStyle(
    color: Colors.white70,
    fontSize: 26.0,
    fontWeight: FontWeight.w100,
    fontFamily: "Saira",
  );
  TextStyle _infoStyle = new TextStyle(
    color: Colors.white,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );
  TextStyle _infoStyleBlue = new TextStyle(
    color: Colors.green,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
  );
  TextStyle _fieldStyle = new TextStyle(
    color: Colors.white,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
  );

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);

    _loginNode.add(new FocusNode());
    _loginNode.add(new FocusNode());

    _blurController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _blurAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_blurController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (_state != -1) {
                _currentState = _state;
                _state = -1;
                _blurController.reverse();
              }
            } else if (status == AnimationStatus.dismissed) {
              //controller.forward();
            }
          });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          key: _scaffoldKey,
          body: _body(),
        ),
        onWillPop: () {
          if (_progress > 0) return new Future<bool>.value(false);

          if (_currentState != 0) {
            _state = 0;
            _blurController.forward();
            return new Future<bool>.value(false);
          } else {
            return showDialog(
                  context: context,
                  builder: (_) => new AlertDialog(
                    title: new Text('Do you want to exit this application?'),
                    content: new Text('We hate to see you leave...'),
                    actions: <Widget>[
                      new MaterialButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: new Text('No'),
                      ),
                      new MaterialButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: new Text('Yes'),
                      ),
                    ],
                  ),
                ).then((value) => value as bool) ??
                false as Future<bool>;
          }
        });
  }

  Widget _background() {
    /*return Image.asset(
      "images/bg.jpg",
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
    );*/
    return Container(
      color: Color(0xFF2A363F),
      height: double.infinity,
      width: double.infinity,
    );
  }

  Widget _backButton() {
    return Visibility(
      child: Opacity(
        opacity: 1.0 - _blurController.value,
        child: Container(
          height: 50.0,
          width: 50.0,
          alignment: Alignment.center,
          margin: EdgeInsets.fromLTRB(
            0.0,
            30.0,
            30.0,
            0.0,
          ),
          child: MaterialButton(
            onPressed: () {
              _state = 0;
              _blurController.forward();
            },
            child: Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.close,
                color: Colors.white70,
                size: 24.0,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),
            ),
          ),
        ),
      ),
      visible: _currentState == 1,
    );
  }

  Widget _logo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0),
      child: Image.asset(
        "images/logo.png",
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _content() {
    return Visibility(
      child: Opacity(
        opacity: 1.0 - _blurController.value,
        child: Container(
            margin: EdgeInsets.fromLTRB(
              30.0,
              30.0,
              30.0,
              0.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 100.0,
                ),
                _logo(),
                SizedBox(
                  height: 40.0,
                ),
                Center(
                  child: Text(
                    "Breakthrough to the next level",
                    style: _infoStyle,
                  ),
                ),
                Expanded(child: Container()),
                SizedBox(
                  height: 80.0,
                ),
                _control(),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                  child: InkWell(
                    child: Container(
                      child: RichText(
                        text: new TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                              text: "FORGOT YOUR PASSWORD? ",
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.0),
                            ),
                            new TextSpan(
                              text: 'RESET NOW',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.0),
                            ),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 40.0,
                    ),
                    onTap: () {},
                  ),
                  type: MaterialType.transparency,
                ),
                SizedBox(
                  height: 10.0,
                ),
              ],
              mainAxisSize: MainAxisSize.max,
            ),
            alignment: Alignment.bottomLeft),
      ),
      visible: _currentState == 0,
    );
  }

  Widget _login() {
    return Visibility(
      child: Opacity(
        opacity: 1.0 - _blurController.value,
        child: Container(
            margin: EdgeInsets.fromLTRB(
              30.0,
              0.0,
              30.0,
              0.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _logo(),
                SizedBox(
                  height: 60,
                ),
                _field(
                  Icons.email,
                  "Email",
                  _loginEmailController,
                  _loginNode,
                  0,
                  false,
                ),
                SizedBox(
                  height: 20.0,
                ),
                _field(
                  Icons.lock,
                  "Password",
                  _loginPasswordController,
                  _loginNode,
                  1,
                  true,
                ),
                SizedBox(
                  height: 60.0,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600.0),
                  child: Row(
                    children: <Widget>[
                      _button(
                        "Sign In",
                        _infoStyleBlue,
                        Colors.white,
                        _doLogin,
                      ),
                    ],
                  ),
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            alignment: Alignment.center),
      ),
      visible: _currentState == 1,
    );
  }

  Widget _field(IconData icons, String label, TextEditingController controller,
      List<FocusNode> node, int pos, bool password) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600.0),
      child: Row(
        children: <Widget>[
          Container(
            child: Icon(
              icons,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: TextField(
              keyboardType:
                  password ? TextInputType.text : TextInputType.emailAddress,
              controller: controller,
              obscureText: password ? _obsText : false,
              textInputAction: node.length - 1 == pos
                  ? TextInputAction.done
                  : TextInputAction.next,
              focusNode: node.elementAt(pos),
              onSubmitted: (_) {
                if (node.length - 1 != pos)
                  FocusScope.of(context).requestFocus(
                    node.elementAt(pos + 1),
                  );
              },
              decoration: InputDecoration(
                suffixIcon: password
                    ? InkWell(
                        child: Icon(
                          _obsText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onTap: () {
                          setState(() {
                            _obsText = !_obsText;
                          });
                        },
                      )
                    : null,
                contentPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                labelText: label,
                labelStyle: _infoStyle,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              style: _fieldStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(
      String text, TextStyle textStyle, Color color, VoidCallback callback) {
    return Expanded(
      child: MaterialButton(
        onPressed: callback,
        child: Container(
          height: 50.0,
          alignment: Alignment.center,
          child: Text(
            text,
            style: textStyle,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        color: color,
      ),
    );
  }

  Widget _control() {
    return Row(
      children: <Widget>[
        /*_button(
          "Sign Up",
          _infoStyle,
          Colors.blue,
          _gotoRegister,
        ),
        SizedBox(
          width: 40.0,
        ),*/
        _button(
          "Sign In",
          _infoStyleBlue,
          Colors.white,
          _gotoLogin,
        ),
      ],
    );
  }

/*  Widget _layer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x881976D2),
            Color.fromARGB(190, 30, 30, 30),
          ],
          stops: [0.0, 0.7],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }*/

  Widget _blur() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: _currentState == 1 ? 6.0 : _blurAnimation.value * 6 + 0.001,
            sigmaY:
                _currentState == 1 ? 6.0 : _blurAnimation.value * 6 + 0.001),
        child: Container(
          color: Colors.black87.withOpacity(0.1),
        ),
      ),
    );
  }

  Widget _builder() {
    if (_progress > 0) {
      return StreamBuilder(
        stream: frontStreamBuilder.member,
        builder: (context, AsyncSnapshot<UserModel?> snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                showMessage(
                    _scaffoldKey as GlobalKey<ScaffoldState>, "Login success");
                _progress = 0;
                if (_currentState == 1) {
                  //_loginEmailController.text = "";
                  final Future<SharedPreferences> _prefs =
                      SharedPreferences.getInstance();
                  final SharedPreferences prefs = await _prefs;

                  prefs
                      .setString(
                    kMemberLower,
                    jsonEncode(
                      snapshot.data!.toJson(),
                    ),
                  )
                      .then((bool success) {
                    if (success) {
                      Navigator.of(context).pushReplacementNamed(kRouteApp);
                    }
                  });
                }
                //if (_currentState == 2) {
                //  frontStreamBuilder.sendToDatabase().then((value) {
                //    print("okeee");
                //    Navigator.of(context).pushReplacementNamed(kRouteApp);
                //   });
                //}
              },
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                if (jsonDecode((snapshot.error as DioError)
                        .response
                        .toString())[kParamStatusCode] ==
                    400) {
                  showMessage(_scaffoldKey as GlobalKey<ScaffoldState>,
                      "Email / password salah");
                } else {
                  showMessage(_scaffoldKey as GlobalKey<ScaffoldState>,
                      snapshot.error.toString());
                }

                setState(
                  () {
                    if (_currentState == 1) {
                      //_loginPasswordController.text = "";
                    }
                    _progress = 0;
                  },
                );
              },
            );
          }

          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black12,
            child: Center(
              child: Lottie.asset(
                'images/loading.json',
                height: 100.0,
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  Widget _body() {
    return Stack(
      children: <Widget>[
        _background(),
        //_layer(),
        _blur(),
        _backButton(),

        _content(),
        _login(),
        _builder(),
      ],
    );
  }

  void _gotoLogin() {
    _state = 1;
    _blurController.forward();
  }

/*  void _gotoRegister() {
    _state = 2;
    _blurController.forward();
  }*/

  void _doLogin() {
    if (_valid()) {
      setState(() {
        _progress = 1;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      frontStreamBuilder.doLogin(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
    }
  }

  bool _valid() {
    if (_currentState == 1 || _currentState == 2) {
      if (_loginEmailController.text.isEmpty) {
        showMessage(
            _scaffoldKey as GlobalKey<ScaffoldState>, "Email cannot empty");
        return false;
      }
      if (_loginPasswordController.text.isEmpty) {
        showMessage(
            _scaffoldKey as GlobalKey<ScaffoldState>, "Password cannot empty");
        return false;
      }
      return true;
    } else {
      return false;
    }
  }
}
