import 'package:flutter/material.dart';

class DescriptionSection extends StatefulWidget {
  final Function drawSubText;
  final String description;
  final String searchWord;
  final double maxHeight;

  const DescriptionSection({
    Key key,
    this.drawSubText,
    this.description,
    this.searchWord = '',
    this.maxHeight = 100,
  }) : super(key: key);

  @override
  _DescriptionSectionState createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<DescriptionSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Row(
          children: <Widget>[
            const SizedBox(
              width: 5,
            ),
            const Icon(Icons.library_books, size: 18),
            const SizedBox(
              width: 5,
            ),
            //TODO: solution pour rendre texte scrollable si dépasse une maxHeight donné: Container+BoxConstraints>SingleChildScrollView>Text
            // TODO: ScrollBar+controller+isAlwaysScrollable > SingleChildScrollView+controller => bar de scroll !
            Expanded(
              child: Container(
                  constraints: BoxConstraints(maxHeight: widget.maxHeight),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(width: 1, color: Colors.grey)),
                  //width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      controller: _scrollController,
                      isAlwaysShown: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: widget.drawSubText == null
                            ? Text(
                                widget.description,
                                overflow: TextOverflow.ellipsis,
                              )
                            : widget.drawSubText(
                                text: widget.description,
                                subText: widget.searchWord),
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
