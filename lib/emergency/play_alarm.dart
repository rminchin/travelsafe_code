import '../emergency/emergency.dart';
import '../emergency/emergency_no_login.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:volume_control/volume_control.dart';

class PlayAlarm extends StatefulWidget {
  final String mode;
  const PlayAlarm({Key? key, required this.mode}) : super(key: key);

  @override
  PlayAlarmState createState() => PlayAlarmState();
}

class PlayAlarmState extends State<PlayAlarm> {
  late AudioPlayer player;
  final path = 'assets/alarm.wav';
  bool _playing = false;
  double _val = 0.5;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {}

  @override
  void dispose() async {
    super.dispose();
    player.dispose();
  }

  void _backScreen() {
    if (widget.mode == "loggedIn") {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const Emergency()),
        ModalRoute.withName('/'),
      );
    } else {
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const EmergencyNoLogin()),
        ModalRoute.withName('/'),
      );
    }
  }

  Future _play() async {
    await player.setAsset(path);
    player.play();
    double val = await VolumeControl.volume;
    VolumeControl.setVolume(1);
    setState(() {
      _val = val;
      _playing = true;
    });
  }

  Future _stop() async {
    player.stop();
    VolumeControl.setVolume(_val);
    setState(() {
      _playing = false;
    });
  }

  Future togglePlaying() async {
    if (player.playing) {
      await _stop();
    } else {
      await _play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("Emergency"),
            leading: BackButton(
              color: Colors.white,
              onPressed: _backScreen,
            )),
        body: Center(
          child: Column(children: [
            ElevatedButton.icon(
                icon: _playing
                    ? const Icon(Icons.stop_outlined)
                    : const Icon(Icons.play_arrow),
                onPressed: () async {
                  await togglePlaying();
                  setState(() {});
                },
                label: Text(_playing ? 'Stop' : 'Play')),
            const SizedBox(height: 30),
          ]),
        ));
  }
}
