import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title, description;
  final Image image;
  final VoidCallback confirmClick;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.confirmClick,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 52.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 40.0),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // To close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                  FlatButton(
                    onPressed: confirmClick,
                    child: Text("Confirm"),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 40.0,
            child: Icon(
              Icons.info,
              size: 40.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
