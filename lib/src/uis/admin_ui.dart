import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:versus/src/components/custom_app_bar.dart';
import 'package:versus/src/models/log_model.dart';
import 'package:versus/src/providers/report_provider.dart';
import 'package:versus/src/providers/setting_provider.dart';

class AdminUI extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<AdminUI> with AfterLayoutMixin {
  BuildContext? _context;
  List<LogModel>? _logs;
  List<LogModel>? _logs2;
  DateTime? time = new DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Report",
      ),
      body: RefreshIndicator(
        child: _body(),
        onRefresh: () {
          refresh();
          return Future.value(true);
        },
      ),
    );
  }

  void refresh() {
    setState(() {
      if (_logs != null) _logs!.clear();
      if (_logs2 != null) _logs2!.clear();
      _logs = null;
      _logs2 = null;
      Provider.of<ReportProvider>(context, listen: false)
          .getLogs(time: time!)
          .then((value) {
        setState(() {
          _logs = value;
        });
      });

      Provider.of<ReportProvider>(context, listen: false)
          .getLogs3(time: time!)
          .then((value) {
        setState(() {
          _logs2 = value;
        });
      });
    });
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SfDateRangePicker(
            onSelectionChanged: (_) {
              setState(() {
                time = _.value;
                refresh();
              });
            },
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: time,
            enablePastDates: true,
            showNavigationArrow: true,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Report Data Entry",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _list(),
          SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              "Report Data Checker",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _list2(),
        ],
      ),
    );
  }

  Widget _list() {
    if (_logs == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    _logs![index].user!.name!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check1",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs![index].edit.toString())
                    ],
                  ),
                ),
                Text("|"),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check2",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs![index].edit2.toString())
                    ],
                  ),
                ),
                Text("|"),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check3",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs![index].edit3.toString())
                    ],
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _logs!.length,
      );
    }
  }

  Widget _list2() {
    if (_logs2 == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (BuildContext context, int index) =>
            Divider(height: 1),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    _logs2![index].user!.name!,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Chat",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs2![index].edit.toString())
                    ],
                  ),
                ),
                Text("|"),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check1",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs2![index].check1.toString())
                    ],
                  ),
                ),
                Text("|"),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check2",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs2![index].check2.toString())
                    ],
                  ),
                ),
                Text("|"),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Check3",
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(_logs2![index].check3.toString())
                    ],
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _logs2!.length,
      );
    }
  }

  Widget _content(String title, MaterialColor colors, IconData icons,
      VoidCallback callback) {
    return InkWell(
      onTap: callback,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 5.0),
        child: ListTile(
          contentPadding: EdgeInsets.all(0.0),
          leading: Container(
            height: 36.0,
            width: 36.0,
            child: Icon(
              icons,
              color: Colors.white,
              size: 18.0,
            ),
            decoration: BoxDecoration(
              color: colors,
              borderRadius: BorderRadius.all(
                Radius.circular(18.0),
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Colors.black,
            size: 22.0,
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 0.15,
      width: double.infinity,
      color: Colors.grey,
      margin: EdgeInsets.only(left: 20.0, right: 20.0),
    );
  }

  void _doLogout() async {
    Provider.of<SettingProvider>(context, listen: false).doLogout(context);
  }
}
