import 'dart:convert';

import 'package:after_layout/after_layout.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/archive_provider.dart';
import 'package:versus/src/providers/filter_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/providers/testing_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/resources/helper.dart' as k;
import 'package:versus/src/resources/popup_card.dart';

class TestingAddUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<TestingAddUI>
    with
        AutomaticKeepAliveClientMixin,
        AfterLayoutMixin,
        SingleTickerProviderStateMixin {
  final GlobalKey _scaffoldKey = new GlobalKey<ScaffoldState>();

  UserModel? user;
  ChatModel? chat;

  late Animation<double> _animation;
  late AnimationController _animationController;

  bool _loading = false;
  bool _isPhoneDetect = false;
  bool _isHighlight = false;
  bool _realtime = false;

  int transaction = 0;

  String? LT = "";
  String? LB = "";
  String? lebar = "";
  String? panjang = "";
  String? posisiLantai = "";
  String? jumlahLantai = "";
  String? KT = "";
  bool splitLevel = false;
  bool minus = false;
  bool lelang = false;
  bool hook = false;
  bool request = false;
  bool multi = false;
  List<String?> price = ["", ""];
  List<String?> permeter = ["", ""];
  List<Money> priceClass = [];
  List<Money> permeterClass = [];
  CurrencyTextInputFormatter formatter =
      CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0);

  TextEditingController _chatController = new TextEditingController();
  TextEditingController _noteController = new TextEditingController();
  TextEditingController _noteController2 = new TextEditingController();

  List<String?> content = [];

  List<SelectAbleModel?> _category = [];
  List<SelectAbleModel?> _certificate = [];
  List<SelectAbleModel?> _toward = [];
  List<SelectAbleModel?> _location = [];
  List<SelectAbleModel?> _area = [];
  List<SelectAbleModel?> _buildingType = [];

  @override
  bool get wantKeepAlive => true;

  bool isAdmin(UserModel? user) {
    if (Provider.of<FilterProvider>(context, listen: false).doneInit) {
      return false;
    }
    return !Provider.of<NoteProvider>(context, listen: false).merge &&
        k.isAdmin(user);
  }

  bool isStaff(UserModel? user) {
    if (Provider.of<FilterProvider>(context, listen: false).doneInit) {
      return false;
    }

    return !Provider.of<NoteProvider>(context, listen: false).merge &&
        k.isStaff(user);
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    MainProvider().getMember().then((value) {
      TestingProvider note =
          Provider.of<TestingProvider>(context, listen: false);
      loadChat(note.chat!, value!);

      if (_realtime) {
        Future.delayed(
            Duration(milliseconds: 100),
            () => note.loadDetail().then((chat) {
                  loadChat(chat!, value);
                }));
      }
    });
  }

  loadChat(ChatModel chat, UserModel value) {
    setState(() {
      _loading = false;
      this.chat = chat;

      _certificate.clear();
      if (chat.certificate != null) {
        _certificate.add(chat.certificate!.selectAbleModel);
      }

      _toward.clear();
      if (chat.toward != null) {
        _toward.add(chat.toward!.selectAbleModel);
      }

      _category.clear();
      if (chat.propertyCategory != null) {
        _category.add(chat.propertyCategory!.selectAbleModel);
      }

      _location.clear();
      if (chat.specificLocation != null) {
        _location.add(chat.specificLocation!.selectAbleModel);
      }

      _buildingType.clear();
      if (chat.buildingType != null) {
        _buildingType.add(chat.buildingType!.selectAbleModel);
      }

      user = value;
      _isHighlight = isStaff(user);

      transaction = 0;
      splitLevel = false;
      LT = "";
      LB = "";
      lelang = false;
      minus = false;
      hook = false;
      request = false;
      multi = false;
      lebar = "";
      panjang = "";
      posisiLantai = "";
      jumlahLantai = "";
      KT = "";
      price = ["", ""];
      permeter = ["", ""];
      priceClass.clear();
      permeterClass.clear();

      if (isStaff(user)) {
        if (chat.transactionTypeID != null) {
          transaction = int.parse(chat.transactionTypeID!);
        }
        if (chat.lT != null) {
          LT = chat.lT;
        }

        if (chat.lB != null) {
          LB = chat.lB;
        }
        minus = chat.minus;
        lelang = chat.lelang;
        hook = chat.hook;
        request = chat.request;
        multi = chat.multi;
        splitLevel = chat.splitLevel;

        if (chat.lebar != null) {
          lebar = chat.lebar;
        }

        if (chat.panjang != null) {
          panjang = chat.panjang;
        }

        if (chat.posisiLantai != null) {
          posisiLantai = chat.posisiLantai;
        }

        if (chat.jumlahLantai != null) {
          jumlahLantai = chat.jumlahLantai;
        }

        if (chat.kT != null) {
          KT = chat.kT;
        }

        if (chat.hargaJual != null) {
          price[0] = chat.hargaJual;
        }
        if (chat.hargaSewa != null) {
          price[1] = chat.hargaSewa;
        }

        if (chat.perMeterJual != null) {
          permeter[0] = chat.perMeterJual;
        }

        if (chat.perMeterSewa != null) {
          permeter[1] = chat.perMeterSewa;
        }

        priceClass.add(new Money(
            new TextEditingController(text: formatter.format(price[0]!))));

        priceClass.add(new Money(
            new TextEditingController(text: formatter.format(price[1]!))));

        permeterClass.add(new Money(
            new TextEditingController(text: formatter.format(permeter[0]!))));
        permeterClass.add(new Money(
            new TextEditingController(text: formatter.format(permeter[1]!))));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (user == null) {
      return Container();
    }

    NoteProvider noteProvider =
        Provider.of<NoteProvider>(context, listen: false);

    ChatModel? chat;

    if (noteProvider.archive) {
      chat = Provider.of<ArchiveProvider>(context, listen: false).chat;
    } else if (noteProvider.testing) {
      chat = Provider.of<TestingProvider>(context, listen: false).chat;
    } else {
      chat = noteProvider.chat;
    }

    String title = chat!.id == null ? "Add Chat" : chat.id.toString();
    if (chat.id != null && chat.chat2 != null) {
      Map<String, dynamic> temp = jsonDecode(chat.chat2!);

      if (temp['testing'] != null) {
        title += ' (${temp['testing']})';
      }
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: title,
            //action: _action(),
            leading: _leading(),
            action: _trailing(),
            callback: () {
              Clipboard.setData(
                ClipboardData(
                  text: chat!.id.toString(),
                ),
              );
            },
          ),
          body: _body(),
          floatingActionButton: chat.id != null ? _fab() : null,
        ),
        Visibility(
          visible: _loading,
          child: Container(
            color: Colors.black38,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _selectTransaction() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: Checkbox(
                  onChanged: (_) {
                    setState(() {
                      if (_!) {
                        transaction += 1;
                      } else {
                        transaction -= 1;
                        price[0] = "";
                        permeter[0] = "";
                        priceClass[0].controller!.text = "";
                        permeterClass[0].controller!.text = "";
                      }
                    });
                  },
                  value: transaction == 1 || transaction == 3,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text("Jual"),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              SizedBox(
                height: 24.0,
                width: 24.0,
                child: Checkbox(
                  onChanged: (_) {
                    setState(() {
                      if (_!) {
                        transaction += 2;
                      } else {
                        transaction -= 2;
                        price[1] = "";
                        permeter[1] = "";
                        priceClass[1].controller!.text = "";
                        permeterClass[1].controller!.text = "";
                      }
                    });
                  },
                  value: transaction == 2 || transaction == 3,
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Text("Sewa"),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget _selectLT() {
    TextEditingController ltController = new TextEditingController(text: LT);
    ltController.addListener(() {
      LT = ltController.text;
      if (ltController.text.length > 0) {
        for (int i = 0; i <= 1; i++) {
          if (price[i] != null &&
              price[i]!.isNotEmpty &&
              LT != null &&
              LT!.isNotEmpty) {
            permeterClass[i].controller!.text = formatter.format(
                (int.parse(price[i]!) / double.parse(LT!)).round().toString());
            permeter[i] = permeterClass[i].controller!.text.replaceAll(".", "");
          }
        }
      }
    });
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              controller: ltController,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'^\d+\.?\d*'), allow: true),
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          PopupItemLauncher(
            tag: "LT",
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.edit,
                size: 18,
              ),
            ),
            popUp: LayoutBuilder(builder: (context, constraints) {
              TextEditingController controller = new TextEditingController();
              return PopUpItem(
                tag: "LT",
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        child: InkWell(
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 24,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        controller: controller,
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp(r'^\d+\.?\d*'),
                              allow: true),
                        ],
                        onChanged: (_) {},
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                double hektar =
                                    double.tryParse(controller.text) ?? 0.0;
                                double meter = hektar * 10000;

                                if (meter % 1 == 0) {
                                  ltController.text = meter.toInt().toString();
                                } else {
                                  ltController.text = meter.toStringAsFixed(2);
                                }

                                Navigator.pop(context);
                              },
                              child: Text("Hektar"),
                              elevation: 1,
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(8),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                elevation: 2,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _selectLB() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: LB),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        LB = _;
        /* if (_.length > 0) {
          for (int i = 0; i <= 1; i++) {
            if (price[i] != null &&
                price[i].isNotEmpty &&
                LB != null &&
                LB.isNotEmpty) {
              permeterClass[i].controller.text = formatter.format(
                  (int.parse(price[i]) / double.parse(LB)).round().toString());
              permeter[i] =
                  permeterClass[i].controller.text.replaceAll(".", "");
            }
          }
        }*/
      },
    ));
  }

  Widget _selectLebarDepan() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: lebar),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        lebar = _;
      },
    ));
  }

  Widget _selectPanjang() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: panjang),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        panjang = _;
      },
    ));
  }

  Widget _selectPosisiLantai() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: posisiLantai),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        posisiLantai = _;
      },
    ));
  }

  Widget _selectJumlahLantai() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: jumlahLantai),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        jumlahLantai = _;
      },
    ));
  }

  Widget _selectSplitLevel() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: splitLevel,
              onChanged: (dynamic _) {
                setState(() {
                  splitLevel = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: splitLevel,
              onChanged: (dynamic _) {
                setState(() {
                  splitLevel = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectLelang() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: lelang,
              onChanged: (dynamic _) {
                setState(() {
                  lelang = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: lelang,
              onChanged: (dynamic _) {
                setState(() {
                  lelang = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectHook() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: hook,
              onChanged: (dynamic _) {
                setState(() {
                  hook = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: hook,
              onChanged: (dynamic _) {
                setState(() {
                  hook = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectRequest() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: request,
              onChanged: (dynamic _) {
                setState(() {
                  request = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: request,
              onChanged: (dynamic _) {
                setState(() {
                  request = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectMulti() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: multi,
              onChanged: (dynamic _) {
                setState(() {
                  multi = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: multi,
              onChanged: (dynamic _) {
                setState(() {
                  multi = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectMinus() {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: RadioListTile(
              value: true,
              groupValue: minus,
              onChanged: (dynamic _) {
                setState(() {
                  minus = _;
                });
              },
              title: Text(
                "Ya",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: RadioListTile(
              value: false,
              groupValue: minus,
              onChanged: (dynamic _) {
                setState(() {
                  minus = _;
                });
              },
              title: Text(
                "Tidak",
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectKT() {
    return Expanded(
        child: TextField(
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: new TextEditingController(text: KT),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
      onChanged: (_) {
        KT = _;
      },
    ));
  }

  Widget _selectPrice(int pos) {
    TextEditingController priceController = priceClass[pos].controller!;
    priceController.addListener(() {
      price[pos] = priceController.text.replaceAll(".", "");

      if (priceClass.elementAt(pos).node!.hasFocus &&
          LT != null &&
          LT!.isNotEmpty) {
        if (priceController.text.length == 0) {
          permeter[pos] = "";
          permeterClass[pos].controller!.text = "";
        } else {
          String res =
              (int.parse(price[pos]!) / double.parse(LT!)).round().toString();
          permeter[pos] = res;
          permeterClass[pos].controller!.text = formatter.format(res);
        }
      }
    });
    return Expanded(
        child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: priceController,
            focusNode: priceClass[pos].node,
            inputFormatters: [formatter],
            keyboardType: TextInputType.number,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        PopupItemLauncher(
          tag: "price" + pos.toString(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.edit,
              size: 18,
            ),
          ),
          popUp: LayoutBuilder(builder: (context, constraints) {
            TextEditingController controller = new TextEditingController();
            priceClass.elementAt(pos).node!.requestFocus();
            return PopUpItem(
              tag: "price" + pos.toString(),
              child: Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      child: InkWell(
                        child: Icon(
                          Icons.cancel_outlined,
                          size: 24,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      alignment: Alignment.centerRight,
                    ),
                    TextField(
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      controller: controller,
                      inputFormatters: [
                        FilteringTextInputFormatter(RegExp(r'^\d+\.?\d*'),
                            allow: true),
                      ],
                      onChanged: (_) {},
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MaterialButton(
                            onPressed: () {
                              double value =
                                  double.tryParse(controller.text) ?? 0.0;

                              priceController.text =
                                  NumberFormat("###,###.##", "id_ID")
                                      .format(value * 1000000)
                                      .replaceAll(',', '.');
                              Navigator.pop(context);
                            },
                            child: Text("Juta"),
                            elevation: 1,
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: MaterialButton(
                            onPressed: () {
                              double value =
                                  double.tryParse(controller.text) ?? 0.0;
                              priceController.text =
                                  NumberFormat("###,###.##", "id_ID")
                                      .format(value * 1000000000)
                                      .replaceAll(',', '.');
                              Navigator.pop(context);
                            },
                            child: Text("Milyar"),
                            elevation: 1,
                            color: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              padding: EdgeInsets.all(8),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              elevation: 2,
            );
          }),
        ),
      ],
    ));
  }

  Widget _selectPermeter(int pos) {
    TextEditingController permeterController = permeterClass[pos].controller!;

    permeterController.addListener(() {
      permeter[pos] = permeterController.text.replaceAll(".", "");

      if (permeterClass.elementAt(pos).node!.hasFocus &&
          LT != null &&
          LT!.isNotEmpty) {
        if (permeterController.text.length == 0) {
          price[pos] = "";
          priceClass[pos].controller!.text = "";
        } else {
          String res = (int.parse(permeter[pos]!) * double.parse(LT!))
              .round()
              .toString();
          price[pos] = res;
          priceClass[pos].controller!.text = formatter.format(res);
        }
      }
    });

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: permeterController,
              focusNode: permeterClass[pos].node,
              inputFormatters: [formatter],
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          PopupItemLauncher(
            tag: "permeter" + pos.toString(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.edit,
                size: 18,
              ),
            ),
            popUp: LayoutBuilder(builder: (context, constraints) {
              TextEditingController controller = new TextEditingController();
              permeterClass.elementAt(pos).node!.requestFocus();
              return PopUpItem(
                tag: "permeter" + pos.toString(),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    children: [
                      Container(
                        child: InkWell(
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 24,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        alignment: Alignment.centerRight,
                      ),
                      TextField(
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        controller: controller,
                        inputFormatters: [
                          FilteringTextInputFormatter(RegExp(r'^\d+\.?\d*'),
                              allow: true),
                        ],
                        onChanged: (_) {},
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                double value =
                                    double.tryParse(controller.text) ?? 0.0;

                                permeterController.text =
                                    NumberFormat("###,###.##", "id_ID")
                                        .format(value * 1000000)
                                        .replaceAll(',', '.');
                                Navigator.pop(context);
                              },
                              child: Text("Juta"),
                              elevation: 1,
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: MaterialButton(
                              onPressed: () {
                                double value =
                                    double.tryParse(controller.text) ?? 0.0;
                                permeterController.text =
                                    NumberFormat("###,###.##", "id_ID")
                                        .format(value * 1000000000)
                                        .replaceAll(',', '.');
                                Navigator.pop(context);
                              },
                              child: Text("Milyar"),
                              elevation: 1,
                              color: Colors.grey[200],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                padding: EdgeInsets.all(8),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32)),
                elevation: 2,
              );
            }),
          ),
        ],
      ),
    );
  }

  String checkPrice(String txt) {
    String temp = txt.replaceAll(".", "");
    List<String> spt = temp.split("").reversed.toList();
    String res = "";
    int index = 0;
    spt.forEach((element) {
      index += 1;
      res = element + res;
      if (index % 3 == 0 && index != spt.length) {
        res = "." + res;
      }
    });
    return res;
  }

  Widget _body() {
    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Consumer<TestingProvider>(builder: (context, value, child) {
              return _innerChild(value);
            }),
          ),
        );
      },
    );
  }

  _innerChild(TestingProvider value) {
    if (value.chat!.chat != null) {
      _chatController.text = value.chat!.chat!;
    }

    if (value.chat!.notes != null) {
      _noteController.text = value.chat!.notes!;
    }

    if (value.chat!.notes2 != null) {
      _noteController2.text = value.chat!.notes2!;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 110.0, child: Text(kTransaksi)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectTransaction()
                : Text(
                    value.chat!.getTransaksi(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(
              width: 110.0,
              child: Text("Kategori"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Expanded(
              child: Wrap(
                spacing: 10.0,
                children: [
                  _category.length == 0
                      ? ActionChip(
                          label: Text("Add +"),
                          onPressed: () async {
                            if (value.categoryDisplay.length > 0) {
                              Provider.of<SelectMasterProvider>(context,
                                      listen: false)
                                  .setData(
                                      single: true,
                                      selectAbleModel: (value.category
                                              as List<PropertyCategoryModel>)
                                          .map((e) => e.selectAbleModel)
                                          .toList(),
                                      selectedModel: _category,
                                      title: kCariKategori);

                              await Navigator.of(context)
                                  .pushNamed(kRouteFriendAdd);
                              _buildingType.clear();
                              setState(() {});
                            }
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                        )
                      : Container(),
                  ..._category
                      .asMap()
                      .map(
                        (i, t) => MapEntry(
                            i,
                            InputChip(
                              label: Text(
                                t!.title!,
                                maxLines: 2,
                                softWrap: true,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _category.removeAt(i);
                                  _buildingType.clear();
                                });
                              },
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3)),
                            )),
                      )
                      .values
                      .toList()
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        false &&
                _category.length > 0 &&
                value.buildingTypes
                    .where((element) =>
                        element.propertyCategory?.id == _category[0]!.id)
                    .isNotEmpty
            ? Row(
                children: [
                  Container(width: 110.0, child: Text("Tipe Bangunan")),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(":"),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 10.0,
                      children: [
                        _buildingType.length == 0
                            ? ActionChip(
                                label: Text("Add +"),
                                onPressed: () async {
                                  if (value.buildingTypesDisplay.length > 0) {
                                    Provider.of<SelectMasterProvider>(context,
                                            listen: false)
                                        .setData(
                                            highlight: value.chat!.chat,
                                            single: true,
                                            selectAbleModel: (value
                                                        .buildingTypes
                                                    as List<BuildingTypesModel>)
                                                .where((element) =>
                                                    element
                                                        .propertyCategory!.id ==
                                                    _category[0]!.id)
                                                .map((e) => e.selectAbleModel)
                                                .toList(),
                                            selectedModel: _buildingType,
                                            title: kCariTipeBangunan);

                                    await Navigator.of(context)
                                        .pushNamed(kRouteFriendAdd);
                                    setState(() {});
                                  }
                                },
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3),
                                ),
                              )
                            : Container(),
                        ..._buildingType
                            .asMap()
                            .map(
                              (i, t) => MapEntry(
                                  i,
                                  InputChip(
                                    label: Text(
                                      t!.title!,
                                      maxLines: 2,
                                      softWrap: true,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _buildingType.removeAt(i);
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                        side: BorderSide(
                                            color: Colors.black, width: 0.3)),
                                  )),
                            )
                            .values
                            .toList()
                      ],
                    ),
                  )
                ],
              )
            : Container(),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Lokasi Spesifik")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Expanded(
              child: Wrap(
                spacing: 10.0,
                children: [
                  _location.length == 0
                      ? ActionChip(
                          label: Text("Add +"),
                          onPressed: () async {
                            if (value.locationDisplay.length > 0) {
                              Provider.of<SelectMasterProvider>(context,
                                      listen: false)
                                  .setData(
                                      single: true,
                                      selectAbleModel: (value.location
                                              as List<SpecificLocationModel>)
                                          .map((e) => e.selectAbleModel)
                                          .toList(),
                                      selectedModel: _location,
                                      title: kCariLokasi);

                              await Navigator.of(context)
                                  .pushNamed(kRouteFriendAdd);
                              setState(() {});
                            }
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                        )
                      : Container(),
                  ..._location
                      .asMap()
                      .map(
                        (i, t) => MapEntry(
                            i,
                            InputChip(
                              label: Builder(builder: (context) {
                                SpecificLocationModel data = (value.location
                                        as List<SpecificLocationModel>)
                                    .firstWhere(
                                        (element) => element.id == t!.id);

                                return Text(
                                  t!.title! +
                                      "\n" +
                                      (data.subArea?.area?.title ?? ""),
                                  maxLines: 2,
                                  softWrap: true,
                                );
                              }),
                              onDeleted: () {
                                setState(() {
                                  _location.removeAt(i);
                                });
                              },
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3)),
                            )),
                      )
                      .values
                      .toList()
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("LT")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectLT()
                : Text(
                    value.chat!.getLuasTanah() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("LB")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectLB()
                : Text(
                    value.chat!.getLuasBangunan() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Lebar")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectLebarDepan()
                : Text(
                    value.chat!.getLebarDepan() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        /*SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Panjang")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectPanjang()
                : Text(
                    value.chat!.getPanjang() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Jumlah Lantai")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectJumlahLantai()
                : Text(
                    value.chat!.getJumlahLantai() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),*/
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Posisi Lantai")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectPosisiLantai()
                : Text(
                    value.chat!.getPosisiLantai() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("KT")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectKT()
                : Text(
                    value.chat!.getKt() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        /*SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Split Level")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectSplitLevel()
                : Text(
                    value.chat!.splitLevel ? "Ya" : "Tidak",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Lelang / Cessie")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectLelang()
                : Text(
                    value.chat!.lelang ? "Ya" : "Tidak",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Ada Minus")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectMinus()
                : Text(
                    value.chat!.minus ? "Ya" : "Tidak",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),*/
        SizedBox(
          height: 20.0,
        ),
        /*
                        Row(
                          children: [
                            Container(width: 110.0, child: Text(kKategori)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(":"),
                            ),
                            Text(
                              value.chat.getKategori(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: [
                            Container(
                                width: 110.0, child: Text(kLokasiSpesifik)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(":"),
                            ),
                            Text(
                              value.chat.getLokasi(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 14.0,
                        ),
                        Row(
                          children: [
                            Container(width: 110.0, child: Text(kLuasTanah)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(":"),
                            ),
                            Text(
                              value.chat.getLuasTanah(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Row(
                          children: [
                            Container(width: 110.0, child: Text(kLuasBangunan)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(":"),
                            ),
                            Text(
                              value.chat.getLuasBangunan(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 14.0,
                        ),*/
        Row(
          children: [
            Container(
              width: 110.0,
              child: Text("Sertifikat"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Expanded(
              child: Wrap(
                spacing: 10.0,
                children: [
                  _certificate.length == 0
                      ? ActionChip(
                          label: Text("Add +"),
                          onPressed: () async {
                            if (value.certificateDisplay.length > 0) {
                              Provider.of<SelectMasterProvider>(context,
                                      listen: false)
                                  .setData(
                                      single: true,
                                      selectAbleModel: value.certificate
                                          .map((e) => e.selectAbleModel)
                                          .toList(),
                                      selectedModel: _certificate,
                                      title: kCariSertifikat);

                              await Navigator.of(context)
                                  .pushNamed(kRouteFriendAdd);

                              setState(() {});
                            }
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                        )
                      : Container(),
                  ..._certificate
                      .asMap()
                      .map(
                        (i, t) => MapEntry(
                            i,
                            InputChip(
                              label: Text(
                                t!.title!,
                                maxLines: 2,
                                softWrap: true,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _certificate.removeAt(i);
                                });
                              },
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3)),
                            )),
                      )
                      .values
                      .toList()
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(
              width: 110.0,
              child: Text("Hadap"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Expanded(
              child: Wrap(
                spacing: 10.0,
                children: [
                  _toward.length == 0
                      ? ActionChip(
                          label: Text("Add +"),
                          onPressed: () async {
                            if (value.towardDisplay.length > 0) {
                              Provider.of<SelectMasterProvider>(context,
                                      listen: false)
                                  .setData(
                                      single: true,
                                      selectAbleModel: value.toward
                                          .map((e) => e.selectAbleModel)
                                          .toList(),
                                      selectedModel: _toward,
                                      title: kCariHadap);

                              await Navigator.of(context)
                                  .pushNamed(kRouteFriendAdd);

                              setState(() {});
                            }
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                        )
                      : Container(),
                  ..._toward
                      .asMap()
                      .map(
                        (i, t) => MapEntry(
                            i,
                            InputChip(
                              label: Text(
                                t!.title!,
                                maxLines: 2,
                                softWrap: true,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _toward.removeAt(i);
                                });
                              },
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3)),
                            )),
                      )
                      .values
                      .toList()
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Hook")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _selectHook(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Request")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _selectRequest(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Multi Spec")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            _selectMulti(),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kHargaJual)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user) && (transaction == 1 || transaction == 3)
                ? _selectPrice(0)
                : Text(
                    value.chat!.getHargaJual(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        false
            ? Row(
                children: [
                  Container(width: 110.0, child: Text(kPerMeterJual)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(":"),
                  ),
                  isStaff(user) && (transaction == 1 || transaction == 3)
                      ? _selectPermeter(0)
                      : Text(
                          value.chat!.getPerMeterJual(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ],
              )
            : Container(),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kHargaSewa)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user) && (transaction == 2 || transaction == 3)
                ? _selectPrice(1)
                : Text(
                    value.chat!.getHargaSewa() ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        false
            ? Row(
                children: [
                  Container(width: 110.0, child: Text(kPerMeterSewa)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(":"),
                  ),
                  isStaff(user) && (transaction == 2 || transaction == 3)
                      ? _selectPermeter(1)
                      : Text(
                          value.chat!.getPerMeterSewa() ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ],
              )
            : Container(),
        SizedBox(
          height: 20.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kTanggalChat)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Text(
              new DateFormat("dd MMM yyyy - hh:mm").format(
                new DateFormat("yyyy-MM-dd").parse(
                  value.chat!.date!,
                ),
              ),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text("Pengirim")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            Text(
              value.chat!.contact == null
                  ? user != null
                      ? user!.user!.name! + " - Versus"
                      : ""
                  : value.chat!.contact!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        SizedBox(
          height: 10.0,
        ),
        Divider(
          color: Colors.black87,
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(value.chat!.chat2 ?? ""),
        SizedBox(
          height: 20.0,
        ),
        _text(value),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buttonDetect(),
        ),
        Visibility(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Notes Admin"),
          ),
          visible: isAdmin(user) || isMarketing(user),
        ),
        Visibility(
          child: TextField(
            controller: _noteController,
            maxLines: null,
            decoration:
                InputDecoration(contentPadding: EdgeInsets.only(bottom: 5)),
          ),
          visible: isAdmin(user),
        ),
        SizedBox(
          height: 20,
        ),
        Visibility(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Notes Pak Joe"),
          ),
          visible: isAdmin(user) || isMarketing(user),
        ),
        Visibility(
          child: TextField(
            controller: _noteController2,
            maxLines: null,
            decoration:
                InputDecoration(contentPadding: EdgeInsets.only(bottom: 5)),
          ),
          visible: isAdmin(user),
        ),
        SizedBox(
          height: 50,
        ),
      ],
    );
  }

  List<Widget> _buttonDetect() {
    List<Widget> _list = [];

    if (k.isStaff(user)) {
      if (!_isHighlight &&
          !_isPhoneDetect &&
          chat != null &&
          chat!.id != null) {
        _list.add(Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Material(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _isHighlight = true;
                  });
                },
                child: Text("Highlight"),
                color: Colors.blue,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
        ));
      }

      if (_isHighlight) {
        _list.add(Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Material(
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    _isHighlight = false;
                  });
                },
                child: Text("Cancel"),
                color: Colors.red,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
        ));
      }
    }

    if (!_isPhoneDetect && !_isHighlight && chat != null && chat!.id != null) {
      _list.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isPhoneDetect = true;
                });
              },
              child: Text("Detect Phone"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      ));
    }

    if (_isPhoneDetect) {
      _list.add(Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isPhoneDetect = false;
                });
              },
              child: Text("Cancel"),
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ),
      ));
    }

    return _list;
  }

  Widget _text(dynamic value) {
    if (_isPhoneDetect) {
      String test = value.chat.chat;
      RegExp r = new RegExp(
          r'(?:0|62)[\s]?(?:[\d]{9,13}|[\d]{3,4}.?[\d]{3,4}.?[\d]{3,5}|[\d]{2}\.[\d]{3}\.?[\d]{3}\.?[\d]{2,4}|[\d]{2,4}\.[\d]{2,4}\.?[\d]{2,4}|[\d]{2,4}[\s]?[\d]{2,4}[\s]?[\d]{2,4})');
      final match = r.allMatches(test);
      int index = 0;
      int loop = 0;

      List<TextSpan> _list = [];
      TextStyle linkStyle = TextStyle(color: Colors.blue);

      if (match.length == 0) {
        _list.add(TextSpan(text: "No phone detected"));
      }

      match.forEach((element) {
        if (index == element.start) {
          _list.add(TextSpan(
              text: element.group(0),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _clickWa(element.group(0)!);
                }));
        } else {
          _list.add(
              TextSpan(text: value.chat.chat.substring(index, element.start)));
          _list.add(TextSpan(
              text: element.group(0),
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _clickWa(element.group(0)!);
                }));
        }

        index = element.end;
        loop += 1;

        if (loop == match.length && index != value.chat.chat.length) {
          _list.add(TextSpan(text: value.chat.chat.substring(index)));
        }
      });

      return RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15.0, height: 1.5, color: Colors.black),
          children: _list,
        ),
      );
    }

    if (!isStaff(user)) {
      return Text(value.chat.chat);
    }

    if (isStaff(user) && _isHighlight && value.chat.chat != null) {
      List<String> textBuilding = [];
      Set<String> textLocationSet = {}; // Menggunakan Set untuk lokasi
      Set<String> textCategorySet = {};
      List<String> keywords = [
        "FR",
        "FS",
        "Jual",
        "Sewa",
        "Rent",
        "Sale"
      ]; // Kata-kata tambahan
      List<String> luasKeywords = [
        "LT",
        "Luas Tanah",
        "Luas"
      ]; // Kata-kata hijau
      List<String> hargaKeywords = [
        "Harga Jual",
        "Harga Sewa",
        "Harga"
      ]; // Kata-kata biru

      // Proses tipe bangunan
      if (_category.isNotEmpty) {
        List<BuildingTypesModel> types = value.buildingTypes
            .where((element) => element.propertyCategory.id == _category[0]!.id)
            .toList();

        types.forEach((element) {
          if (element.include != null) {
            List<String> ele1 = element.include!.split("\n");
            ele1.forEach((element2) {
              List<String> ele2 = element2.split(",");
              ele2.forEach((ele) {
                if (!textBuilding.contains(ele.trim())) {
                  textBuilding.add(ele.trim());
                }
              });
            });
          }
        });
      }

      // Proses lokasi menggunakan Set untuk pencarian cepat
      value.location.forEach((element) {
        if (element.title != null) {
          textLocationSet.add(element.title!.toLowerCase());
        }
      });

      value.category.forEach((element) {
        if (element.title != null) {
          textCategorySet.add(element.title!.toLowerCase());
        }
      });

      String chatText = value.chat.chat.toLowerCase();
      String? buildingPattern = textBuilding.isNotEmpty
          ? textBuilding.join('|')
          : null; // Gabungkan pola untuk tipe bangunan
      String keywordPattern =
          keywords.join('|'); // Gabungkan pola untuk kata-kata tambahan
      String luasPattern = luasKeywords.join('|'); // Gabungkan pola untuk Luas
      String hargaPattern =
          hargaKeywords.join('|'); // Gabungkan pola untuk Harga

      RegExp? buildingRegExp = buildingPattern != null
          ? RegExp(buildingPattern)
          : null; // RegExp untuk tipe bangunan
      RegExp keywordRegExp = RegExp(keywordPattern,
          caseSensitive: false); // RegExp untuk kata-kata tambahan
      RegExp luasRegExp =
          RegExp(luasPattern, caseSensitive: false); // RegExp untuk kata Luas
      RegExp hargaRegExp =
          RegExp(hargaPattern, caseSensitive: false); // RegExp untuk kata Harga

      int currentIndex = 0;
      List<TextSpan> textSpans = [];
      TextStyle highlightBuildingStyle = TextStyle(
        backgroundColor: Colors.yellow,
      );
      TextStyle highlightCategoryStyle = TextStyle(
        backgroundColor: Colors.orange[400],
      );
      TextStyle highlightLocationStyle = TextStyle(
        backgroundColor: Colors.red,
      );
      TextStyle highlightKeywordStyle = TextStyle(
        backgroundColor:
            Colors.purple[200], // Warna ungu untuk kata-kata tambahan
      );
      TextStyle highlightLuasStyle = TextStyle(
        backgroundColor: Colors.green, // Warna hijau untuk Luas
      );
      TextStyle highlightHargaStyle = TextStyle(
        backgroundColor: Colors.blue, // Warna biru untuk Harga
      );

      while (currentIndex < chatText.length) {
        bool isMatched = false;

        // Cari frasa tipe bangunan
        final buildingMatch = buildingRegExp != null
            ? buildingRegExp.matchAsPrefix(chatText, currentIndex)
            : null;
        // Cari kata kunci (FR, FS, Jual, Sewa, Rent, Sale)
        final keywordMatch =
            keywordRegExp.matchAsPrefix(chatText, currentIndex);
        // Cari kata Luas (LT, Luas Tanah, Luas)
        final luasMatch = luasRegExp.matchAsPrefix(chatText, currentIndex);
        // Cari kata Harga (Harga Jual, Harga Sewa)
        final hargaMatch = hargaRegExp.matchAsPrefix(chatText, currentIndex);

        // Jika ada yang cocok, tambahkan ke textSpans
        if (buildingMatch != null) {
          textSpans.add(TextSpan(
            text: buildingMatch.group(0),
            style: highlightBuildingStyle,
          ));
          currentIndex = buildingMatch.end;
          isMatched = true;
        } else if (keywordMatch != null) {
          textSpans.add(TextSpan(
            text: keywordMatch.group(0),
            style: highlightKeywordStyle,
          ));
          currentIndex = keywordMatch.end;
          isMatched = true;
        } else if (luasMatch != null) {
          textSpans.add(TextSpan(
            text: luasMatch.group(0),
            style: highlightLuasStyle,
          ));
          currentIndex = luasMatch.end;
          isMatched = true;
        } else if (hargaMatch != null) {
          textSpans.add(TextSpan(
            text: hargaMatch.group(0),
            style: highlightHargaStyle,
          ));
          currentIndex = hargaMatch.end;
          isMatched = true;
        } else {
          for (var category in textCategorySet) {
            if (chatText.startsWith(category, currentIndex)) {
              textSpans.add(TextSpan(
                text: category,
                style: highlightCategoryStyle,
              ));
              currentIndex += category.length;
              isMatched = true;
              break; // Keluar dari loop setelah menemukan yang cocok
            }
          }

          // Cari frasa lokasi, mulai dari frasa terpanjang
          if (!isMatched) {
            for (var location in textLocationSet) {
              if (chatText.startsWith(location, currentIndex)) {
                textSpans.add(TextSpan(
                  text: location,
                  style: highlightLocationStyle,
                ));
                currentIndex += location.length;
                isMatched = true;
                break; // Keluar dari loop setelah menemukan yang cocok
              }
            }
          }
        }

        // Jika tidak ada yang cocok, tambahkan karakter satu per satu
        if (!isMatched) {
          textSpans.add(TextSpan(
            text: chatText[currentIndex],
            style: TextStyle(fontSize: 15.0, height: 1.5, color: Colors.black),
          ));
          currentIndex++;
        }
      }

      TextStyle keteranganStyle = TextStyle(color: Colors.red);

      // Render RichText dengan highlight yang sesuai
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style:
                  TextStyle(fontSize: 15.0, height: 1.5, color: Colors.black),
              children: textSpans,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "Biru = Harga",
            style: keteranganStyle,
            // style: TextStyle(color: Colors.blue),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Kuning = Tipe Bangunan", style: keteranganStyle,
            //  style: TextStyle(color: Colors.yellow),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Oranye = Kategori", style: keteranganStyle,
            //   style: TextStyle(color: Colors.orange[400]),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Merah = Lokasi", style: keteranganStyle,
            // style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Ungu = Transaksi", style: keteranganStyle,
            // style: TextStyle(color: Colors.purple[200]),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Hijau = Luas", style: keteranganStyle,
            //style: TextStyle(color: Colors.green),
          ),
        ],
      );
    }

    return TextField(
      controller: _chatController,
      style: TextStyle(fontSize: 15.0, height: 1.5),
      maxLines: null,
      decoration: InputDecoration(contentPadding: EdgeInsets.only(bottom: 10)),
    );
  }

  _clickWa(String text) async {
    String temp = text.replaceAll(RegExp(r'[^\d ]+'), "");
    temp = temp.replaceAll(" ", "");
    if (temp.substring(0, 1) == "0") {
      temp = "62" + temp.substring(1);
    }
    await launch("https://wa.me/" + temp);
  }

  Widget _leading() {
    return Container(
      width: 60.0,
      height: 60.0,
      padding: EdgeInsets.all(10.0),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.chevron_left,
          color: Colors.black,
        ),
      ),
    );
  }

  List<Widget> _trailing() {
    TestingProvider provider =
        Provider.of<TestingProvider>(context, listen: false);

    return [
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: chat?.checker != null &&
                  (user!.user!.id != 4029 && user!.user!.id != 4135)
              ? null
              : InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    _save();
                  },
                  child: Icon(
                    Icons.check,
                    color: Colors.black,
                  ),
                ),
        ),
        visible: isStaff(user),
      )
    ];
  }

  Widget _fab() {
    return Container();
  }

  void save() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void saveCallback() {
    showMessage(_scaffoldKey as GlobalKey<ScaffoldState>, "Note updated");
  }

  void _save() async {
    setState(() {
      _loading = true;
    });

    int index = 0;
    Provider.of<TestingProvider>(context, listen: false)
        .editTesting(param: _param())
        .then((value) {
      setState(() {
        _loading = false;

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Update success"),
        ));
      });
    });
  }

  void _delete() {
    showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text("Delete Confirmation"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text('Are you sure want to delete this chat?'),
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _loading = true;
                    });

                    Provider.of<NoteProvider>(context, listen: false)
                        .deleteChat([
                      Provider.of<NoteProvider>(context, listen: false).chat
                    ]).then((value) {
                      Navigator.of(this.context).pop();
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                        content: Text("Delete success"),
                      ));
                    });
                  },
                ),
                CupertinoDialogAction(
                  child: Text("CANCEL"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  Map<String, dynamic> _param({bool forceChecker = false}) {
    Map<String, dynamic> res = {};

    List<Param> _par = [];
    _par.add(new Param("lelang", lelang));
    _par.add(new Param("minus", minus));
    _par.add(new Param("chat", _chatController.text));
    _par.add(new Param("hook", hook));
    _par.add(new Param("request", request));
    _par.add(new Param("multi", multi));

    if (isAdmin(user)) {
      _par.add(new Param("notes", _noteController.text));

      if (_noteController2.text.isNotEmpty) {
        _par.add(new Param("notes2", _noteController2.text));
        _par.add(new Param("error", true));
      }
    }

    if (user!.user!.id == 4029 || user!.user!.id == 4135) {
      _par.add(new Param("checker", user!.user!.id));
    }

    if (isStaff(user)) {
      if (_category.length == 0) {
        _par.add(new Param(kParamPropertyCategory, null));
      } else {
        _par.add(new Param(kParamPropertyCategory, _category[0]!.id));
      }

      if (_location.length == 0) {
        _par.add(new Param(kParamSpecificLocation, null));
      } else {
        _par.add(new Param(kParamSpecificLocation, _location[0]!.id));
      }

      if (_certificate.length == 0) {
        _par.add(new Param(kParamSertifikatLower, null));
      } else {
        _par.add(new Param(kParamSertifikatLower, _certificate[0]!.id));
      }

      if (_toward.length == 0) {
        _par.add(new Param(kParamHadapLower, null));
      } else {
        _par.add(new Param(kParamHadapLower, _toward[0]!.id));
      }

      if (_buildingType.length == 0) {
        _par.add(new Param(kParamBuildingType, null));
      } else {
        _par.add(new Param(kParamBuildingType, _buildingType[0]!.id));
      }
    }
    _par.add(new Param("split_level", splitLevel));
    _par.add(new Param("LT", LT == null || LT!.isEmpty ? null : LT));
    _par.add(new Param("LB", LB == null || LB!.isEmpty ? null : LB));
    _par.add(
        new Param("lebar", lebar == null || lebar!.isEmpty ? null : lebar));
    _par.add(new Param(
        "panjang", panjang == null || panjang!.isEmpty ? null : panjang));
    _par.add(new Param("posisi_lantai",
        posisiLantai == null || posisiLantai!.isEmpty ? null : posisiLantai));
    _par.add(new Param("jumlah_lantai",
        jumlahLantai == null || jumlahLantai!.isEmpty ? null : jumlahLantai));
    _par.add(new Param("KT", KT == null || KT!.isEmpty ? null : KT));
    _par.add(new Param("update_agent", new DateTime.now().toIso8601String()));
    _par.add(new Param("HargaJual", price[0]));
    _par.add(new Param("HargaSewa", price[1]));
    _par.add(new Param("perMeterJual", permeter[0]));
    _par.add(new Param("perMeterSewa", permeter[1]));
    _par.add(new Param(
        "TransactionTypeID", transaction == 0 ? null : transaction.toString()));

    _par.forEach((element) {
      if (element.value == null ||
          ((element is String) && element.value.isEmpty)) {
        res[element.key] = null;
      } else {
        res[element.key] = element.value;
      }
    });

    return res;
  }
}

class Money {
  TextEditingController? controller;
  FocusNode? node;

  Money(TextEditingController controller) {
    this.controller = controller;
    node = new FocusNode();
  }
}

class Param {
  String key;
  dynamic value;

  Param(this.key, this.value);
}
