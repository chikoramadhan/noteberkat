import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:note_berkat/src/resources/helper.dart';
import 'package:note_berkat/src/streams/front_stream.dart';

class FrontPageUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<FrontPageUI> with SingleTickerProviderStateMixin {
  Animation<double> _blurAnimation;
  AnimationController _blurController;

  final TextEditingController _loginEmailController =
      new TextEditingController();
  final TextEditingController _loginPasswordController =
      new TextEditingController();

  final List<FocusNode> _loginNode = new List();

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
    color: Colors.white70,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
  );
  TextStyle _infoStyleBlue = new TextStyle(
    color: Colors.blue,
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

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

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
                  child: new AlertDialog(
                    title: new Text('Do you want to exit this application?'),
                    content: new Text('We hate to see you leave...'),
                    actions: <Widget>[
                      new FlatButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: new Text('No'),
                      ),
                      new FlatButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: new Text('Yes'),
                      ),
                    ],
                  ),
                ) ??
                false;
          }
        });
  }

  Widget _background() {
    return Image.asset(
      "images/bg.jpg",
      fit: BoxFit.cover,
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
                Text(
                  "NOTE",
                  style: _titleStyle,
                ),
                Text(
                  "BERKAT",
                  style: _subtitleStyle,
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  "Lorem ipsum dolor sit amet",
                  style: _infoStyle,
                ),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  "consectetur adipiscing elit. Integer arcu.",
                  style: _infoStyle,
                ),
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
              mainAxisSize: MainAxisSize.min,
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
              30.0,
              30.0,
              0.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "NOTE",
                      style: _titleStyle,
                    ),
                    Text(
                      "BERKAT",
                      style: _subtitleStyle,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                ),
                SizedBox(
                  height: 50.0,
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

  Widget _register() {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      "NOTE",
                      style: _titleStyle,
                    ),
                    Text(
                      "BERKAT",
                      style: _subtitleStyle,
                    ),
                  ],
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                ),
                SizedBox(
                  height: 50.0,
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
                        "Sign Up",
                        _infoStyle,
                        Colors.blue,
                        _doRegister,
                      ),
                    ],
                  ),
                ),
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            alignment: Alignment.center),
      ),
      visible: _currentState == 2,
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
        _button(
          "Sign Up",
          _infoStyle,
          Colors.blue,
          _gotoRegister,
        ),
        SizedBox(
          width: 40.0,
        ),
        _button(
          "Sign In",
          _infoStyleBlue,
          Colors.white,
          _gotoLogin,
        ),
      ],
    );
  }

  Widget _layer() {
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
  }

  Widget _blur() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: _currentState == 1 ? 6.0 : _blurAnimation.value * 6,
            sigmaY: _currentState == 1 ? 6.0 : _blurAnimation.value * 6),
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
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                showMessage(_scaffoldKey, "Login success");
                if (_currentState == 1) {
                  _loginEmailController.text = "";
                  Navigator.of(context).pushReplacementNamed(kRouteApp);
                }
                if (_currentState == 2) {
                  frontStreamBuilder.sendToDatabase().then((value) {
                    Navigator.of(context).pushReplacementNamed(kRouteApp);
                  });
                }
              },
            );
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                showMessage(_scaffoldKey, snapshot.error.toString());
                setState(
                  () {
                    if (_currentState == 1) {
                      _loginPasswordController.text = "";
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
        _layer(),
        _blur(),
        _backButton(),
        _content(),
        _login(),
        _register(),
        _builder(),
      ],
    );
  }

  void _gotoLogin() {
    _state = 1;
    _blurController.forward();
  }

  void _gotoRegister() {
    _state = 2;
    _blurController.forward();
  }

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

  void _doRegister() {
    if (_valid()) {
      setState(() {
        _progress = 1;
      });
      FocusScope.of(context).requestFocus(FocusNode());
      frontStreamBuilder.doRegister(
        _loginEmailController.text,
        _loginPasswordController.text,
      );
    }
  }

  bool _valid() {
    if (_currentState == 1 || _currentState == 2) {
      if (_loginEmailController.text.isEmpty) {
        showMessage(_scaffoldKey, "Email cannot empty");
        return false;
      }
      if (_loginPasswordController.text.isEmpty) {
        showMessage(_scaffoldKey, "Password cannot empty");
        return false;
      }
      return true;
    } else {
      return false;
    }
  }
}
