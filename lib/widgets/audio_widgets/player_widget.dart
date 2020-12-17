import 'dart:async';
import 'dart:io' as io;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }
enum PlayingRouteState { speakers, earpiece }

class PlayerWidget extends StatefulWidget {
  final String url;
  final PlayerMode mode;
  final Widget titleWidget;

  PlayerWidget(
      {Key key,
      @required this.url,
      this.mode = PlayerMode.MEDIA_PLAYER,
      this.titleWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState(url, mode);
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String url;
  PlayerMode mode;

  AudioPlayer _audioPlayer;
  AudioPlayerState _audioPlayerState;
  Duration _duration;
  Duration _position;
  String _maxDurationText;

  double fact = 0.4;

  PlayerState _playerState = PlayerState.stopped;
  PlayingRouteState _playingRouteState = PlayingRouteState.speakers;
  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;
  StreamSubscription _playerErrorSubscription;
  StreamSubscription _playerStateSubscription;

  get _isPlaying => _playerState == PlayerState.playing;
  get _isPaused => _playerState == PlayerState.paused;
  get _durationText => _duration?.toString()?.split('.')?.first ?? '';
  get _positionText => _position?.toString()?.split('.')?.first ?? '';

  _PlayerWidgetState(this.url, this.mode);

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    // Iddée pour éviter bug de 1:39:..
    /* Future.delayed(Duration(milliseconds: 10),(){
      _play().then((_) => _stop());

    }); */
  }

  @override
  void deactivate() {
    _stop().then((value) => _audioPlayer.dispose());
    super.deactivate();
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerErrorSubscription?.cancel();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      color: Colors.blueGrey[50],
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            if (widget.titleWidget != null) widget.titleWidget,
            Row(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 8.0),
                          overlayShape:
                              RoundSliderOverlayShape(overlayRadius: 16.0),
                        ),
                        child: Slider(
                          onChanged: (v) {
                            final position = v * _duration.inMilliseconds;
                            _audioPlayer
                                .seek(Duration(milliseconds: position.round()));
                          },
                          value: (_position != null &&
                                  _duration != null &&
                                  _position.inMilliseconds > 0 &&
                                  _position.inMilliseconds <
                                      _duration.inMilliseconds)
                              ? _position.inMilliseconds /
                                  _duration.inMilliseconds
                              : 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          key: Key('play_button'),
                          onPressed: _isPlaying ? null : () => _play(),
                          iconSize: fact * 64.0,
                          icon: Icon(Icons.play_arrow),
                          color: Theme.of(context).primaryColor,
                        ),
                        IconButton(
                          key: Key('pause_button'),
                          onPressed: _isPlaying ? () => _pause() : null,
                          iconSize: fact * 64.0,
                          icon: Icon(Icons.pause),
                          color: Theme.of(context).primaryColor,
                        ),
                        IconButton(
                          key: Key('stop_button'),
                          onPressed:
                              _isPlaying || _isPaused ? () => _stop() : null,
                          iconSize: fact * 64.0,
                          icon: Icon(Icons.stop),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                    Expanded(
                      child: Text(
                        _position != null
                            ? '${_positionText ?? ''} / ${_durationText ?? ''}'
                            : '0:00:00 / ${_maxDurationText ?? ''}',
                        /* : _duration != null ? _durationText : '', */
                        style: TextStyle(
                          fontSize: fact * 34.0,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer(mode: mode);

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      if (!mounted) return;
      setState(() {});
    });

    _positionSubscription =
        _audioPlayer.onAudioPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
      if (!mounted) return;
      setState(() {
        _position = _duration;
      });
    });

    _playerErrorSubscription = _audioPlayer.onPlayerError.listen((msg) {
      print('audioPlayer error : $msg');
      if (!mounted) return;
      setState(() {
        _playerState = PlayerState.stopped;
        _duration = Duration(seconds: 0);
        _position = Duration(seconds: 0);
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlayerState = state;
      });
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _audioPlayerState = state);
    });

    _playingRouteState = PlayingRouteState.speakers;

    _audioPlayer.setUrl(url).then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        _audioPlayer.getDuration().then((value) {
          if (!mounted) return;
          setState(() {
            Duration maxDuration = Duration(
              milliseconds: value,
            );
            _maxDurationText = maxDuration?.toString()?.split('.')?.first ?? '';
          });
        });
      });
    });
  }

  Future<int> _play() async {
    final playPosition = (_position != null &&
            _duration != null &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;
    final result = await _audioPlayer.play(url, position: playPosition);
    if (result == 1 && mounted)
      setState(() => _playerState = PlayerState.playing);

    // default playback rate is 1.0
    // this should be called after _audioPlayer.play() or _audioPlayer.resume()
    // this can also be called everytime the user wants to change playback rate in the UI
    _audioPlayer.setPlaybackRate(playbackRate: 1.0);

    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1 && mounted)
      setState(() => _playerState = PlayerState.paused);
    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      if (!mounted) return 0;
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration();
      });
    }
    return result;
  }

  void _onComplete() {
    if (!mounted) return;
    setState(() => _playerState = PlayerState.stopped);
  }
}
