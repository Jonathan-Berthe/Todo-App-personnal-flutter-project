
// TODO: gérer l'ordre d'affichage

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_marie/widgets/reutilisable_widgets/delete_button.dart';

import '../audio_widgets/audio_widget.dart';
import '../audio_widgets/player_widget.dart';

import '../../models/record.dart';

import '../audio_widgets/title_audio_player_widget.dart';

class AudioRecorder extends StatefulWidget {
  final String id;
  final Function addRecord;
  final Function deleteRecord;
  final List<Record> records;
  const AudioRecorder(
      {Key key, this.id, this.addRecord, this.records, this.deleteRecord})
      : super(key: key);

  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  List<Record> _records;
  int _editingIndex = -1;

  final TextStyle _nameStyle =
      TextStyle(fontWeight: FontWeight.normal, fontSize: 18);

  @override
  void initState() {
    _records = [...widget.records];
    super.initState();
  }

  void _audioPicker({Record editingRecord}) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    // TODO: mettre dans snipped code comment rajouter le keyboard en padding bottom pour que le bottomsheet monte si on ouvre le keybord (ex with teextfield)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // nécessaire pour le padding
      builder: (BuildContext ctx) {
        return GestureDetector(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx)
                    .viewInsets
                    .bottom), // nécessaire pour le padding
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.5 +
                  MediaQuery.of(ctx)
                      .viewInsets
                      .bottom, // nécessaire pour le padding
            ),
            child: AudioWidget(
              todoId: widget.id,
              numberOfRecord: (_records == null) ? 0 : _records.length,
            ),
          ),
          behavior: HitTestBehavior.opaque,
        );
      },
    ).then((record) {
      if (record == null) return;
      widget.addRecord(record);
      setState(() {
        _records.add(record);
      });
    });
  }

  void _submit(String value, int i) {
    _records[i].setName(value);
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    setState(() {
      _editingIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RaisedButton.icon(
          label: Text('New audio record'),
          icon: Icon(Icons.mic),
          onPressed: _audioPicker,
        ),
        if (_records != null && _records.length > 0)
          Container(
            height: min(150 * _records.length.toDouble(), 450),
            child: ListView.builder(
              physics: _records.length < 4
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              itemBuilder: (ctx, i) {
                return Row(
                  children: <Widget>[
                    Flexible(
                      child: PlayerWidget(
                        url: _records[i].url,
                        titleWidget: TitleAudioPlayerWidget(
                          initName: _records[i].name,
                          setName: (String value) {
                            _submit(value, i);
                          },
                        ),
                      ),
                    ),
                    DeleteButton(
                      objectToDelete: 'audio record',
                      ifDelete: () {
                        widget.deleteRecord(i);
                        setState(() {
                          _records.removeAt(i);
                        });
                      },
                    ),
                  ],
                );
              },
              itemCount: _records.length,
            ),
          ),
      ],
    );
  }
}
