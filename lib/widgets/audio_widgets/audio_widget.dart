// TODO: find file location (activity.getApplicationContext().getFilesDir() + "/" + fileName + ".aac";)

import 'dart:io' as io;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:file/local.dart';
import 'package:medcorder_audio/medcorder_audio.dart';
import 'package:path_provider/path_provider.dart' as systpaths;

import '../../models/record.dart';

import 'title_audio_player_widget.dart';
import 'player_widget.dart';

class AudioWidget extends StatefulWidget {
  final String todoId;
  final int numberOfRecord;
  AudioWidget({this.todoId, this.numberOfRecord});
  @override
  _AudioWidgetState createState() => new _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  MedcorderAudio audioModule = new MedcorderAudio();
  bool canRecord = false;
  double recordPower = 0.0;
  double recordPosition = 0.0;
  bool isRecord = false;
  bool isPlay = false;
  double playPosition = 0.0;
  String file = "";
  String _filePath = '';
  LocalFileSystem fs = LocalFileSystem();
  //Track _track;
  bool _isFinish = false;
  bool _toSave = false;
  String _appDocPath = "";

  String _name;

  @override
  initState() {
    _name = 'Record ${widget.numberOfRecord + 1}' ?? '';
    audioModule.setCallBack((dynamic data) {
      _onEvent(data);
    });
    _initSettings();
    super.initState();
  }

  @override
  void deactivate() {
    if (isRecord) {
      _stopRecord().then((_) => io.File(_filePath).exists().then((value) {
            if (value) io.File(_filePath).delete();
          }));
    } else {
      io.File(_filePath).exists().then((value) {
        if (value && !_toSave) {
          io.File(_filePath).delete();
        }
      });
    }

    super.deactivate();
  }

  Future _initSettings() async {
    final String result = await audioModule.checkMicrophonePermissions();
    if (result == 'OK') {
      await audioModule.setAudioSettings();
      if (mounted)
        setState(() {
          canRecord = true;
        });
    }
    io.Directory appDocDir = await systpaths.getApplicationSupportDirectory();
    _appDocPath = appDocDir.path;
    return;
  }

  Future _startRecord() async {
    try {
      _filePath = _appDocPath + "/" + file + ".aac";
      if (file != '')
        await io.File(_filePath).exists().then((value) async {
          if (value) io.File(_filePath).delete();
          await io.File(_filePath).exists().then((val) {
            if (!val) print("delete ! ");
          });
        });

      DateTime time = new DateTime.now();

      file = '${widget.todoId}_' + time.millisecondsSinceEpoch.toString();

      final String result = await audioModule.startRecord(file);
      if (mounted)
        setState(() {
          isRecord = true;
          _isFinish = false;
        });
      print('startRecord: ' + result);
    } catch (e) {
      file = "";
      print('startRecord: fail');
    }
  }

  Future _stopRecord() async {
    try {
      final String result = await audioModule.stopRecord();
      print('stopRecord: ' + result);
      _filePath = _appDocPath + "/" + file + ".aac";
      print(_filePath);
      bool check = await io.File(_filePath).exists();
      print('exist ?? => ' + check.toString());

      if (mounted)
        setState(() {
          isRecord = false;
          _isFinish = true;
        });
    } catch (e) {
      print('stopRecord: fail');
      if (mounted)
        setState(() {
          isRecord = false;
        });
    }
  }

  void _onEvent(dynamic event) {
    if (event['code'] == 'recording') {
      double power = event['peakPowerForChannel'];
      if (mounted)
        setState(() {
          recordPower = (60.0 - power.abs().floor()).abs();
          recordPosition = event['currentTime'];
        });
    }
    if (event['code'] == 'playing') {
      if (mounted)
        setState(() {
          playPosition = event['currentTime'];
          isPlay = true;
        });
    }
    if (event['code'] == 'audioPlayerDidFinishPlaying') {
      if (mounted)
        setState(() {
          playPosition = 0.0;
          isPlay = false;
        });
    }
  }

  void _setName(String name) {
    _name = name;
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: canRecord
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  iconSize: isRecord ? 50 : 40,
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    if (isRecord) {
                      _stopRecord();
                    } else {
                      _startRecord();
                    }
                  },
                  color: isRecord ? Colors.red : Colors.green,
                ),
                (_isFinish)
                    ? Text(
                        'New record',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )
                    : Text('recording: ' +
                        recordPosition.toStringAsFixed(1) +
                        ' seconds'),
                SizedBox(height: 30),
                if (_isFinish)
                  PlayerWidget(
                    url: _filePath,
                    titleWidget: TitleAudioPlayerWidget(
                      setName: _setName,
                      initName: _name,
                    ), //_titleWidgetBuilder(),
                  ),
                if (_isFinish) SizedBox(height: 10),
                if (_isFinish)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Add record: ',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        iconSize: 40,
                        color: Theme.of(context).primaryColor,
                        icon: Icon(Icons.add_circle),
                        onPressed: () {
                          _toSave = true;
                          Navigator.of(context)
                              .pop(Record(url: _filePath, name: _name));
                        },
                      ),
                    ],
                  ),
              ],
            )
          : new Text(
              'Microphone Access Disabled.\nYou can enable access in Settings',
              textAlign: TextAlign.center,
            ),
    );
  }
}
