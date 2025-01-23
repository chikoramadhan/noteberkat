import 'package:flutter/material.dart';

class DynamicSliverAppBar extends StatefulWidget {
  final Widget child;
  final double maxHeight;
  final Widget title;
  final int timestamp;

  DynamicSliverAppBar({
    required this.child,
    required this.maxHeight,
    required this.title,
    required this.timestamp,
    Key? key,
  }) : super(key: key);

  @override
  _DynamicSliverAppBarState createState() => _DynamicSliverAppBarState();
}

class _DynamicSliverAppBarState extends State<DynamicSliverAppBar> {
  final GlobalKey _childKey = GlobalKey();
  bool isHeightCalculated = false;
  double? height;
  int temp = 0;

  @override
  Widget build(BuildContext context) {
    if (temp != widget.timestamp) isHeightCalculated = false;
    temp = widget.timestamp;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!isHeightCalculated) {
        isHeightCalculated = true;
        setState(() {
          height = (_childKey.currentContext!.findRenderObject() as RenderBox)
              .size
              .height;
        });
      }
    });

    return SliverAppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: widget.title,
      pinned: true,
      snap: true,
      floating: true,
      titleSpacing: 0,
      expandedHeight: isHeightCalculated ? height : widget.maxHeight,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          children: [
            Container(
              key: _childKey,
              child: widget.child,
            ),
            Expanded(child: SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
