import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/components/custom_text_selection_file.dart';
import 'package:versus/src/models/agent_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/photo_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/selectable_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/temp_agent_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/archive_provider.dart';
import 'package:versus/src/providers/filter_provider.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/providers/note_provider.dart';
import 'package:versus/src/providers/request_provider.dart';
import 'package:versus/src/providers/select_master_provider.dart';
import 'package:versus/src/providers/testing_provider.dart';
import 'package:versus/src/resources/helper.dart';
import 'package:versus/src/resources/helper.dart' as k;
import 'package:versus/src/resources/popup_card.dart';

class NoteAddUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<NoteAddUI>
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
  bool _isSpliting = false;
  bool _isPhoneDetect = false;
  bool _isHighlight = false;
  bool _isLinkDetect = false;
  bool _realtime = false;

  int transaction = 0;

  String? LT = "";
  String? LB = "";
  String? lebar = "";
  String? posisiLantai = "";
  String? KT = "";
  bool minus = false;
  bool request = false;
  bool lelang = false;
  bool hook = false;
  bool multi = false;
  String? updateAgent;
  List<String?> price = ["", ""];
  List<String?> permeter = ["", ""];
  List<Money> priceClass = [];
  List<Money> permeterClass = [];
  CurrencyTextInputFormatter formatter =
      CurrencyTextInputFormatter(locale: "id", symbol: "", decimalDigits: 0);

  TextEditingController _chatController = new TextEditingController();
  TextEditingController _noteController = new TextEditingController();
  TextEditingController _noteController2 = new TextEditingController();

  String? header, footer;
  List<String?> content = [];
  List<TextEditingController> _linkController = [];
  List<dynamic> _photoPath = [];

  List<SelectAbleModel?> _tag = [];
  List<SelectAbleModel?> _category = [];
  List<SelectAbleModel?> _location = [];
  List<SelectAbleModel?> _area = [];
  List<SelectAbleModel?> _buildingType = [];
  List<TempAgentModel> _agentJson = [];
  List<SelectAbleModel?> _certificate = [];
  List<SelectAbleModel?> _toward = [];

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
      NoteProvider note = Provider.of<NoteProvider>(context, listen: false);
      if (note.archive) {
        ArchiveProvider archive =
            Provider.of<ArchiveProvider>(context, listen: false);
        loadChat(archive.chat, value!);

        if (_realtime) {
          Future.delayed(
              Duration(milliseconds: 100),
              () => archive.loadDetail().then((chat) {
                    loadChat(chat, value);
                  }));
        }
      } else if (note.testing) {
        TestingProvider testing =
            Provider.of<TestingProvider>(context, listen: false);

        loadChat(testing.chat, value!);

        if (_realtime) {
          Future.delayed(
              Duration(milliseconds: 100),
              () => testing.loadDetail().then((chat) {
                    loadChat(chat, value);
                  }));
        }
      } else {
        loadChat(note.chat, value!);

        if (_realtime) {
          Future.delayed(
              Duration(milliseconds: 100),
              () => note.loadDetail().then((chat) {
                    loadChat(chat, value);
                  }));
        }
      }
    });
  }

  loadChat(ChatModel? chat, UserModel value) {
    setState(() {
      _loading = false;
      this.chat = chat;

      _certificate.clear();
      if (chat!.certificate != null) {
        _certificate.add(chat.certificate!.selectAbleModel);
      }

      _toward.clear();
      if (chat.toward != null) {
        _toward.add(chat.toward!.selectAbleModel);
      }

      _tag.clear();
      if (chat.tag != null)
        _tag.addAll(chat.tag!.map((e) => e.selectAbleModel).toList());

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

      updateAgent = chat.updateAgent;
      user = value;
      _isHighlight = isStaff(user);

      transaction = 0;
      LT = "";
      LB = "";
      posisiLantai = "";
      KT = "";
      lebar = "";
      lelang = false;
      hook = false;
      minus = false;
      request = false;
      multi = false;
      price = ["", ""];
      permeter = ["", ""];
      priceClass.clear();
      permeterClass.clear();

      if (isStaff(user)) {
        if (chat.agentJson != null) {
          _agentJson = List.from(chat.agentJson!["agent"])
              .map((e) => TempAgentModel.fromJson(e))
              .toList();
        }

        if (chat.transactionTypeID != null) {
          transaction = int.parse(chat.transactionTypeID!);
        }
        if (chat.lT != null) {
          LT = chat.lT;
        }

        if (chat.lB != null) {
          LB = chat.lB;
        }

        if (chat.posisiLantai != null) {
          posisiLantai = chat.posisiLantai;
        }

        if (chat.lebar != null) {
          lebar = chat.lebar;
        }

        if (chat.kT != null) {
          KT = chat.kT;
        }

        minus = chat.minus;
        lelang = chat.lelang;
        request = chat.request;
        multi = chat.multi;

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

      _linkController.clear();
      _photoPath.clear();
      if (isAdmin(user) || isMarketing(user)) {
        if (chat.linkPhoto != null) {
          List<String> linkPhoto = chat.linkPhoto!.split("\n");
          linkPhoto.forEach((element) {
            _linkController.add(new TextEditingController(text: element));
          });
        }

        if (chat.photo != null) {
          chat.photo!.forEach((element) {
            _photoPath.add(element);
          });
        }
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

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: chat!.id == null ? "Add Chat" : chat.id.toString(),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                isAdmin(user) &&
                        _photoPath
                                .where((element) => element is String)
                                .length >
                            0
                    ? Container(
                        color: Colors.white,
                        width: double.infinity,
                        child: Material(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Upload image " +
                                  (_photoPath.length -
                                          _photoPath
                                              .where((element) =>
                                                  element is String)
                                              .length)
                                      .toString() +
                                  "/" +
                                  _photoPath.length.toString()),
                            ),
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        )
      ],
    );
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

  Widget _selectMultiSpec() {
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
    Consumer consumer;

    if (Provider.of<NoteProvider>(context, listen: false).archive) {
      consumer = Consumer<ArchiveProvider>(builder: (context, value, child) {
        return _innerChild(value);
      });
    } else if (Provider.of<NoteProvider>(context, listen: false).testing) {
      consumer = Consumer<TestingProvider>(builder: (context, value, child) {
        return _innerChild(value);
      });
    } else {
      consumer = Consumer<NoteProvider>(builder: (context, value, child) {
        return _innerChild(value);
      });
    }

    return LayoutBuilder(
      builder: (context, constraint) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: consumer,
          ),
        );
      },
    );
  }

  _innerChild(value) {
    if (value.chat.chat != null) {
      _chatController.text = value.chat.chat;
    }

    if (value.chat.notes != null) {
      _noteController.text = value.chat.notes;
    }

    if (value.chat.notes2 != null) {
      _noteController2.text = value.chat.notes2;
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
                    value.chat.getTransaksi(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        isStaff(user)
            ? Row(
                children: [
                  Container(width: 110.0, child: Text("Kategori")),
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
                                                    as List<
                                                        PropertyCategoryModel>)
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
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3),
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
          height: isStaff(user) ? 10 : 0,
        ),
        isStaff(user) &&
                _category.length > 0 &&
                value.buildingTypes
                    .where((element) =>
                        element.propertyCategory.id == _category[0]!.id)
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
                                            highlight: value.chat.chat,
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
          height: isStaff(user) ? 10 : 0,
        ),
        isStaff(user)
            ? Row(
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
                                                    as List<
                                                        SpecificLocationModel>)
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
                                  side: BorderSide(
                                      color: Colors.black, width: 0.3),
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
                                      SpecificLocationModel data = (value
                                                  .location
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
            Container(width: 110.0, child: Text("LT")),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user)
                ? _selectLT()
                : Text(
                    value.chat.getLuasTanah(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("LB")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectLB(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 20.0 : 0,
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
            Container(width: 110.0, child: Text(kHargaJual)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user) && (transaction == 1 || transaction == 3)
                ? _selectPrice(0)
                : Text(
                    value.chat.getHargaJual(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kPerMeterJual)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user) && (transaction == 1 || transaction == 3)
                ? _selectPermeter(0)
                : Text(
                    value.chat.getPerMeterJual(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: isStaff(user) ? 20 : 10,
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
                    value.chat.getHargaSewa(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Container(width: 110.0, child: Text(kPerMeterSewa)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(":"),
            ),
            isStaff(user) && (transaction == 2 || transaction == 3)
                ? _selectPermeter(1)
                : Text(
                    value.chat.getPerMeterSewa(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
          ],
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
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
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
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
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Hook")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectHook(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Posisi Lantai")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectPosisiLantai(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
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
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("KT")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectKT(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Lelang / Cessie")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectLelang(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Ada Minus")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectMinus(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Request")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectRequest(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 10 : 0,
        ),
        Visibility(
          child: Row(
            children: [
              Container(width: 110.0, child: Text("Multi Spec")),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(":"),
              ),
              _selectMultiSpec(),
            ],
          ),
          visible: isStaff(user),
        ),
        SizedBox(
          height: isStaff(user) ? 20 : 10,
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
                  value.chat.date,
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
              value.chat.contact == null
                  ? user != null
                      ? user!.user!.name! + " - Versus"
                      : ""
                  : value.chat.contact,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        isAdmin(user)
            ? Column(
                children: [
                  Row(
                    children: [
                      Container(width: 110.0, child: Text("Editor")),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(":"),
                      ),
                      Text(
                        (value.chat as ChatModel).editor != null &&
                                (value.chat as ChatModel).editor!.id != null
                            ? value.chat.editor.name
                            : "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Container(width: 110.0, child: Text("Checker")),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(":"),
                      ),
                      Text(
                        (value.chat as ChatModel).checker != null &&
                                (value.chat as ChatModel).checker!.id != null
                            ? value.chat.checker.name
                            : "",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Container(width: 110.0, child: Text("Update Agent")),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(":"),
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            value.chat.updateAgent ?? "Select Date",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900]),
                          ),
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: new DateTime.now(),
                              firstDate: new DateTime.now().subtract(
                                Duration(days: 365),
                              ),
                              lastDate: new DateTime.now().add(
                                Duration(days: 365),
                              ),
                              currentDate: value.chat.updateAgent != null
                                  ? new DateFormat("yyyy-MM-dd")
                                      .parse(value.chat.updateAgent)
                                  : null);

                          if (date != null) {
                            setState(() {
                              value.chat.updateAgent =
                                  date.toString().split(" ")[0];
                              updateAgent = value.chat.updateAgent;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              )
            : Container(),
        isStaff(user)
            ? Row(
                children: [
                  Container(width: 110.0, child: Text("Tag")),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(":"),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 10.0,
                      children: [
                        ActionChip(
                          label: Text("Add +"),
                          onPressed: () async {
                            setState(() {
                              _loading = true;
                            });
                            Provider.of<NoteProvider>(context, listen: false)
                                .getTag(cache: true)
                                .then((v) async {
                              setState(() {
                                _loading = false;
                              });

                              Provider.of<SelectMasterProvider>(context,
                                      listen: false)
                                  .setData(
                                selectAbleModel: v.map((e) {
                                  SelectAbleModel selectModel =
                                      new SelectAbleModel(
                                          id: e.id,
                                          title: e.name,
                                          trailing: e.chat.toString());
                                  return selectModel;
                                }).toList(),
                                selectedModel: _tag,
                                title: "Search tag by name",
                              );

                              await Navigator.of(context)
                                  .pushNamed(kRouteFriendAdd);

                              setState(() {});
                            });
                          },
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                        ),
                        ..._tag
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
                                        _tag.removeAt(i);
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
        _tempAgent(),
        SizedBox(
          height: 10.0,
        ),
        _listAgent(),
        SizedBox(
          height: 10.0,
        ),
        isAdmin(user) &&
                value.chat?.check != null &&
                value.chat?.check == true &&
                value.chat?.check2 != null &&
                value.chat?.check2 == true &&
                value.chat?.checker == null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: FloatingActionButton(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                                title: Text("Checker Confirmation"),
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: new Text(
                                      'Are you sure want to set checker selected chat?'),
                                ),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: Text("OK"),
                                    isDestructiveAction: true,
                                    onPressed: () {
                                      Navigator.of(context).pop();

                                      _save(forceChecker: true);
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
                    },
                  ),
                ),
              )
            : Container(),
        Divider(
          color: Colors.black87,
        ),
        SizedBox(
          height: 10.0,
        ),
        _text(value),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buttonDetect(),
        ),
        ...splitMode(),
        Visibility(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Notes 1"),
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
          visible: isAdmin(user) && !_isLinkDetect,
        ),
        Visibility(
          child: Linkify(
            text: _noteController.text,
            style: TextStyle(fontSize: 16),
            onOpen: (_) {
              launchUrl(Uri.parse(_.url));
            },
          ),
          visible: isMarketing(user) || _isLinkDetect,
        ),
        Visibility(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text("Notes 2"),
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
          visible: isAdmin(user) && !_isLinkDetect,
        ),
        Visibility(
          child: Linkify(
            text: _noteController2.text,
            style: TextStyle(fontSize: 16),
            onOpen: (_) {
              launchUrl(Uri.parse(_.url));
            },
          ),
          visible: isMarketing(user) || _isLinkDetect,
        ),
        Visibility(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Material(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      _isLinkDetect = true;
                    });
                  },
                  child: Text("Detect Link"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
          ),
          visible: isAdmin(user) && !_isLinkDetect,
        ),
        Visibility(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Material(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      _isLinkDetect = false;
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
          ),
          visible: isAdmin(user) && _isLinkDetect,
        ),
        _photo(),
        ..._linkController.map(
          (e) {
            if (isAdmin(user) && !_isLinkDetect) {
              return ListTile(
                title: TextField(
                  controller: e,
                ),
                trailing: InkWell(
                  child: Icon(Icons.delete),
                  onTap: () {
                    setState(() {
                      _linkController.remove(e);
                    });
                  },
                ),
              );
            } else {
              return Linkify(
                text: e.text,
                style: TextStyle(fontSize: 16),
                onOpen: (_) {
                  launchUrl(Uri.parse(_.url));
                },
              );
            }
          },
        ),
        Visibility(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Material(
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      _linkController.add(new TextEditingController());
                    });
                  },
                  child: Text("Add Photo Link"),
                  color: Colors.blue,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
          ),
          visible: isAdmin(user) &&
              !_isSpliting &&
              !_isPhoneDetect &&
              !_isLinkDetect,
        ),
      ],
    );
  }

  Widget _tempAgent() {
    Widget widget = Container();

    if (_agentJson.isNotEmpty && isStaff(user) && chat!.checker == null) {
      widget = Column(
        children: _agentJson.map((e) => _widgetTempAgent(e)).toList(),
      );
    }

    return widget;
  }

  Widget _widgetTempAgent(TempAgentModel data) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 50, child: Text("Nama")),
                SizedBox(
                  width: 10,
                ),
                Text(":"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: data.namaController,
                  ),
                ),
              ],
            ),
            Divider(
              height: 50,
            ),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text("Hp"),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(":"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: data.hpController
                        .map(
                          (e) => TextField(
                            controller: e,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _listAgent() {
    Widget widget = Container();

    if (chat!.agents.isNotEmpty && isStaff(user) && chat!.checker != null) {
      widget = Column(
        children: chat!.agents.map((e) => _widgetAgent(e)).toList(),
      );
    }

    return widget;
  }

  Widget _widgetAgent(AgentModel agent) {
    TextStyle _style = new TextStyle(
      height: 1.5,
    );

    List<Widget> _agentInfo = [];

    _agentInfo.add(Text(agent.name ?? "", style: _style));

    _agentInfo.add(Text(
      agent.phone ?? "",
      style: _style,
    ));

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text('Agent id : ${agent.id}'),
              Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _agentInfo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buttonDetect() {
    List<Widget> _list = [];

    if (k.isStaff(user)) {
      if (!_isSpliting &&
          !_isHighlight &&
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

    if (!_isSpliting &&
        !_isPhoneDetect &&
        !_isHighlight &&
        chat != null &&
        chat!.id != null) {
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

  Widget _photo() {
    if (!isAdmin(user) && !isMarketing(user)) {
      return Container();
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ..._photoPath.map(
              (e) => Container(
                margin: EdgeInsets.only(right: 15.0),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: e is PhotoModel
                            ? Image.network(
                                e.url!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                new File(e as String),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Visibility(
                      visible: isAdmin(user),
                      child: InkWell(
                        child: Container(
                            margin: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                        onTap: () {
                          setState(() {
                            _photoPath.remove(e);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isAdmin(user),
              child: InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  final List<XFile> images = await _picker.pickMultiImage(
                    maxWidth: 1024,
                    maxHeight: 1024,
                  );

                  setState(() {
                    images.forEach((element) async {
                      _photoPath.add(element.path);
                    });
                  });
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Icon(Icons.add),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    if (_isSpliting) {
      return new SelectableText(
        value.chat.chat,
        style: TextStyle(fontSize: 15.0, height: 1.5),
        enableInteractiveSelection: _isSpliting,
        toolbarOptions: ToolbarOptions(
            copy: false, selectAll: false, cut: false, paste: false),
        selectionControls: CustomTextSelectionControls(
          header: (start, end) {
            setState(() {
              header = value.chat.chat.substring(start, end);
            });
          },
          footer: (start, end) {
            setState(() {
              footer = value.chat.chat.substring(start, end);
            });
          },
          content: (start, end) {
            setState(() {
              content.add(value.chat.chat.substring(start, end));
            });
          },
        ),
      );
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
          ? RegExp(buildingPattern!)
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

  List<Widget> splitMode() {
    if (!_isSpliting) {
      return [];
    }
    return [
      SizedBox(
        height: 10.0,
      ),
      Divider(
        color: Colors.black87,
        thickness: 5.0,
      ),
      SizedBox(
        height: 10.0,
      ),
      Visibility(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Header',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      header = null;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(header == null ? "" : header!),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
        visible: header != null,
      ),
      ...content.map((e) {
        // ignore: sdk_version_ui_as_code
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Content ${content.indexOf(e) + 1}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      content.remove(e);
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(e!),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        );
      }).toList(),
      Visibility(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Footer",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  width: 20.0,
                ),
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      footer = null;
                    });
                  },
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(footer == null ? "" : footer!),
            SizedBox(
              height: 20.0,
            ),
            Divider(
              color: Colors.black87,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
        visible: footer != null,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Material(
            child: MaterialButton(
              onPressed: () {
                setState(() {
                  _isSpliting = false;
                  header = null;
                  footer = null;
                  content.clear();
                });
              },
              child: Text("Cancel"),
              color: Colors.blue,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          Material(
            child: MaterialButton(
              onPressed: () {
                if (content.length > 0) {
                  showDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                            title: Text("Split Confirmation"),
                            content: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new Text(
                                  'Are you sure want to split this chat?'),
                            ),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text("OK"),
                                isDestructiveAction: true,
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _loading = true;
                                  });

                                  NoteProvider provider =
                                      Provider.of<NoteProvider>(context,
                                          listen: false);
                                  for (var chat in content) {
                                    String temp = "";
                                    if (header != null) {
                                      temp += header! + "\n\n";
                                    }
                                    temp += chat!;
                                    if (footer != null) {
                                      temp += "\n\n" + footer!;
                                    }
                                    await provider.addChat(temp);
                                  }

                                  await provider.deleteChat([provider.chat]);
                                  Navigator.of(this.context).pop();

                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(SnackBar(
                                    content: Text("Split success"),
                                  ));
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
                } else {
                  showMessage(_scaffoldKey as GlobalKey<ScaffoldState>,
                      "Content masih kosong");
                }
              },
              child: Text("Save"),
              color: Colors.red,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
        ],
      ),
    ];
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
    NoteProvider provider = Provider.of<NoteProvider>(context, listen: false);
    if (provider.merge) return [];

    if (provider.testing) {
      return [];
    }
    if (provider.archive) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () {
            _restore();
          },
        ),
      ];
    }

    return [
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              ChatModel? chat =
                  Provider.of<NoteProvider>(context, listen: false).chat;

              chatToClipboard([chat], user, context,
                  full: Provider.of<RequestProvider>(context, listen: false)
                          .request ==
                      null);
            },
            child: Icon(
              Icons.copy,
              color: Colors.black,
            ),
          ),
        ),
        visible: provider.chat != null && provider.chat!.id != null,
      ),
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              _delete();
            },
            child: Icon(
              Icons.delete,
              color: Colors.black,
            ),
          ),
        ),
        visible: isAdmin(user) && provider.chat!.id != null,
      ),
      Visibility(
        child: Container(
          width: 50.0,
          height: 50.0,
          padding: EdgeInsets.all(5.0),
          child: InkWell(
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
        visible: isStaff(user) && !_isSpliting,
      )
    ];
  }

  Widget _fab() {
    if (isAdmin(user) && !_isSpliting) {
      return FloatingActionBubble(
        // Menu items
        items: <Bubble>[
          // Floating action menu item
          Bubble(
            title: "Merge",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.merge_type,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () async {
              Provider.of<NoteProvider>(context, listen: false).merge = true;
              _animationController.reverse();
              await Navigator.of(context).pushNamed(kRouteMerge);

              Provider.of<NoteProvider>(context, listen: false).merge = false;
            },
          ),
          // Floating action menu item
          //Floating action menu item
          Bubble(
            title: "Split",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.call_split,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              setState(() {
                _isSpliting = true;
                _isPhoneDetect = false;
              });
              _animationController.reverse();
            },
          ),
          Bubble(
            title: "History",
            iconColor: Colors.white,
            bubbleColor: Colors.blue,
            icon: Icons.history,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            onPress: () {
              _animationController.reverse();
              Navigator.of(context).pushNamed(kRouteHistory);
            },
          ),
        ],

        // animation controller
        animation: _animation,

        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),

        // Floating Action button Icon color
        iconColor: Colors.blue,

        // Flaoting Action button Icon
        iconData: Icons.settings,
        backGroundColor: Colors.white,
      );
    } else {
      return Container();
    }
  }

  void save() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void saveCallback() {
    showMessage(_scaffoldKey as GlobalKey<ScaffoldState>, "Note updated");
  }

  void _save({bool forceChecker = false}) async {
    setState(() {
      _loading = true;
    });

    int index = 0;
    NoteProvider provider = Provider.of<NoteProvider>(context, listen: false);

    await Future.forEach(_photoPath, (dynamic element) async {
      if (!(element is PhotoModel)) {
        PhotoModel photo = await provider.uploadPhoto(path: element);
        setState(() {
          _photoPath[index] = photo;
        });
      }

      index += 1;
    });

    Provider.of<NoteProvider>(context, listen: false)
        .editChat(param: _param(forceChecker: forceChecker))
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

  void _restore() {
    showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text("Restore Confirmation"),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text('Are you sure want to restore this chat?'),
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

                    Provider.of<ArchiveProvider>(context, listen: false)
                        .restoreChat([
                      Provider.of<ArchiveProvider>(context, listen: false).chat
                    ]).then((value) {
                      Navigator.of(this.context).pop();
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                        content: Text("Restore success"),
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
    if (forceChecker) {
      res["forceChecker"] = true;
    }
    _par.add(new Param("chat", _chatController.text));
    _par.add(new Param("lelang", lelang));
    _par.add(new Param("hook", hook));
    _par.add(new Param("minus", minus));
    _par.add(new Param("request", request));
    _par.add(new Param("multi", multi));

    if (isAdmin(user)) {
      _par.add(new Param("notes", _noteController.text));
      _par.add(new Param("notes2", _noteController2.text));
      _par.add(new Param("update_agent", updateAgent));

      if (_linkController.length == 0) {
        _par.add(new Param("link_photo", null));
      } else {
        _par.add(new Param(
            "link_photo",
            _linkController
                .where((element) => element.text.isNotEmpty)
                .map((e) => e.text)
                .join("\n")));
      }

      if (_photoPath.length == 0) {
        _par.add(new Param("photo", null));
      } else {
        _par.add(new Param(
            "photo", _photoPath.map((e) => (e as PhotoModel).id).toList()));
      }
    }

    if (isStaff(user)) {
      _par.add(new Param("tags", _tag.map((e) => e!.id).toList()));
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

      if (_buildingType.length == 0) {
        _par.add(new Param(kParamBuildingType, null));
      } else {
        _par.add(new Param(kParamBuildingType, _buildingType[0]!.id));
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
    }

    _par.add(new Param("LT", LT == null || LT!.isEmpty ? null : LT));
    _par.add(new Param("LB", LB == null || LB!.isEmpty ? null : LB));
    _par.add(
        new Param("lebar", lebar == null || lebar!.isEmpty ? null : lebar));
    _par.add(new Param("posisi_lantai",
        posisiLantai == null || posisiLantai!.isEmpty ? null : posisiLantai));
    _par.add(new Param("KT", KT == null || KT!.isEmpty ? null : KT));
    _par.add(new Param("HargaJual", price[0]));
    _par.add(new Param("HargaSewa", price[1]));
    _par.add(new Param("perMeterJual", permeter[0]));
    _par.add(new Param("perMeterSewa", permeter[1]));
    _par.add(new Param(
        "TransactionTypeID", transaction == 0 ? null : transaction.toString()));

    if (Provider.of<NoteProvider>(context, listen: false).chat!.id == null) {
      _par.add(new Param("date", new DateTime.now().toIso8601String()));
      _par.add(new Param("contact", user!.user!.name! + " - Versus"));
    }

    _par.forEach((element) {
      if (element.value == null ||
          ((element is String) && element.value.isEmpty)) {
        res[element.key] = null;
      } else {
        res[element.key] = element.value;
      }
    });

    print(res);

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
