import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:todo_marie/widgets/task_content.dart/task_widget.dart';

class ScrollTasks extends StatefulWidget {
  final Function onReorder;
  final List<TaskWidget> listOfTaskWidg;
  final Function setSize;
  final ScrollController scrollController;
  final double maxHeight;

  const ScrollTasks({Key key, this.onReorder, this.listOfTaskWidg, this.setSize, this.scrollController, this.maxHeight = 350.0})
      : super(key: key);

  @override
  _ScrollTasksState createState() => _ScrollTasksState();
}

class _ScrollTasksState extends State<ScrollTasks> {
  final GlobalKey _key = GlobalKey();
  bool _isScrollable = false;
  double _height = 0;


  _checkHeight() {
    if (_key.currentContext == null) return;
    RenderBox _cardBox = _key.currentContext.findRenderObject();

    if (_cardBox.size.height == _height) return;

    if (_cardBox.size.height == widget.maxHeight && !_isScrollable) {
      setState(() {
        _isScrollable = true;
      });
    } else if (_cardBox.size.height < widget.maxHeight && _isScrollable) {
      setState(() {
        _isScrollable = false;
      });
    }

    _height = _cardBox.size.height;

    widget.setSize(_height);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkHeight());
    // But: faire aller le scroll tout en bas de la liste quand ca rebuild
    return Container(
      key: _key,
      constraints: BoxConstraints(maxHeight: widget.maxHeight.toDouble(), minHeight: 0),
      child: CustomScrollView(
        shrinkWrap: true,
        controller: widget.scrollController,
        physics: !_isScrollable
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          ReorderableSliverList(
            onReorder: widget.onReorder,
            onNoReorder: (index) {},
            delegate: ReorderableSliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return widget.listOfTaskWidg[index];
              },
              childCount: widget.listOfTaskWidg.length,
            ),
          ),
        ],
      ),
    );
  }
}
