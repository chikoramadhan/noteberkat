import 'package:flutter/material.dart';

typedef OffsetValue = void Function(int start, int end);

class CustomTextSelectionControls extends MaterialTextSelectionControls {
  // Padding between the toolbar and the anchor.
  static const double _kToolbarContentDistanceBelow = 20.0;
  static const double _kToolbarContentDistance = 8.0;
  CustomTextSelectionControls({this.header, this.footer, this.content});

  /// Custom
  final OffsetValue? header;
  final OffsetValue? footer;
  final OffsetValue? content;

  /// Builder for material-style copy/paste text selection toolbar.
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
        globalEditableRegion.left + selectionMidpoint.dx,
        globalEditableRegion.top +
            startTextSelectionPoint.point.dy -
            textLineHeight -
            _kToolbarContentDistance);
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return MyTextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      clipboardStatus: clipboardStatus,
      handleCopy: canCopy(delegate) && handleCopy != null
          ? () => handleCopy(delegate, clipboardStatus)
          : null,

      /// Custom code
      header: () {
        header!(delegate.textEditingValue.selection.start,
            delegate.textEditingValue.selection.end);
        delegate.userUpdateTextEditingValue(
            delegate.textEditingValue.copyWith(
              selection: TextSelection.collapsed(
                offset: delegate.textEditingValue.selection.baseOffset,
              ),
            ),
            SelectionChangedCause.tap);
        /*delegate.textEditingValue = delegate.textEditingValue.copyWith(
          selection: TextSelection.collapsed(
            offset: delegate.textEditingValue.selection.baseOffset,
          ),
        );*/
        delegate.hideToolbar();
      },
      footer: () {
        footer!(delegate.textEditingValue.selection.start,
            delegate.textEditingValue.selection.end);
        delegate.userUpdateTextEditingValue(
            delegate.textEditingValue.copyWith(
              selection: TextSelection.collapsed(
                offset: delegate.textEditingValue.selection.baseOffset,
              ),
            ),
            SelectionChangedCause.tap);
        delegate.hideToolbar();
      },
      content: () {
        content!(delegate.textEditingValue.selection.start,
            delegate.textEditingValue.selection.end);
        delegate.userUpdateTextEditingValue(
            delegate.textEditingValue.copyWith(
              selection: TextSelection.collapsed(
                offset: delegate.textEditingValue.selection.baseOffset,
              ),
            ),
            SelectionChangedCause.tap);
        delegate.hideToolbar();
      },
      handleCut: canCut(delegate) && handleCut != null
          ? () => handleCut(delegate)
          : null,
      handlePaste: canPaste(delegate) && handlePaste != null
          ? () => handlePaste(delegate)
          : null,
      handleSelectAll: canSelectAll(delegate) && handleSelectAll != null
          ? () => handleSelectAll(delegate)
          : null,
    );
  }
}

class MyTextSelectionToolbar extends StatefulWidget {
  const MyTextSelectionToolbar({
    Key? key,
    this.anchorAbove,
    this.anchorBelow,
    this.clipboardStatus,
    this.handleCopy,
    this.handleCut,
    this.handlePaste,
    this.handleSelectAll,

    /// Custom
    this.header,
    this.footer,
    this.content,
  }) : super(key: key);

  final Offset? anchorAbove;
  final Offset? anchorBelow;
  final ClipboardStatusNotifier? clipboardStatus;
  final VoidCallback? handleCopy;
  final VoidCallback? handleCut;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;

  /// Custom
  final VoidCallback? header;
  final VoidCallback? footer;
  final VoidCallback? content;

  @override
  MyTextSelectionToolbarState createState() => MyTextSelectionToolbarState();
}

class MyTextSelectionToolbarState extends State<MyTextSelectionToolbar> {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus!.addListener(_onChangedClipboardStatus);
    widget.clipboardStatus!.update();
  }

  @override
  void didUpdateWidget(MyTextSelectionToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus!.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus!.removeListener(_onChangedClipboardStatus);
    }
    widget.clipboardStatus!.update();
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.clipboardStatus!.disposed) {
      widget.clipboardStatus!.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    final List<_TextSelectionToolbarItemData> itemDatas =
        <_TextSelectionToolbarItemData>[
      if (widget.handleCut != null)
        _TextSelectionToolbarItemData(
          label: localizations.cutButtonLabel,
          onPressed: widget.handleCut,
        ),
      if (widget.handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: widget.handleCopy,
        ),
      if (widget.handlePaste != null &&
          widget.clipboardStatus!.value == ClipboardStatus.pasteable)
        _TextSelectionToolbarItemData(
          label: localizations.pasteButtonLabel,
          onPressed: widget.handlePaste,
        ),
      if (widget.handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: widget.handleSelectAll,
        ),
      _TextSelectionToolbarItemData(
        onPressed: widget.header,
        label: 'Header',
      ),
      _TextSelectionToolbarItemData(
        onPressed: widget.content,
        label: 'Content',
      ),
      _TextSelectionToolbarItemData(
        onPressed: widget.footer,
        label: 'Footer',
      ),
    ];

    int childIndex = 0;
    return TextSelectionToolbar(
      anchorAbove: widget.anchorAbove!,
      anchorBelow: widget.anchorBelow!,
      toolbarBuilder: (BuildContext context, Widget child) {
        return Card(child: child);
      },
      children: itemDatas.map((_TextSelectionToolbarItemData itemData) {
        return TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(
              childIndex++, itemDatas.length),
          onPressed: itemData.onPressed,
          child: Text(itemData.label!),
        );
      }).toList(),
    );
  }
}

class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    this.label,
    this.onPressed,
  });

  final String? label;
  final VoidCallback? onPressed;
}
