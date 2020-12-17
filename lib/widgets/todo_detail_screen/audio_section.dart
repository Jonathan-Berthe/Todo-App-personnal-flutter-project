import 'dart:math';

import 'package:flutter/material.dart';
import '../audio_widgets/player_widget.dart';

import '../../models/record.dart';

class AudioSection extends StatelessWidget {
  final List<Record> records;

  AudioSection({
    Key key,
    this.records,
  }) : super(key: key);

  final TextStyle _nameStyle =
      TextStyle(fontWeight: FontWeight.normal, fontSize: 18);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (records != null && records.length > 0)
          Container(
            height: min(150 * records.length.toDouble(), 450),
            child: ListView.builder(
              physics: records.length < 4
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                return Row(
                  children: <Widget>[
                    Flexible(
                      child: PlayerWidget(
                        url: records[i].url,
                        titleWidget: Container(
                          margin: EdgeInsets.all(8),
                          child: Row(
                            children: <Widget>[
                              Text(
                                records[i].name,
                                style: _nameStyle,
                              ),
                              Expanded(
                                child: SizedBox(),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              itemCount: records.length,
            ),
          ),
      ],
    );
  }
}
