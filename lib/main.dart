import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayer2/audioplayer2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KRA MUSIC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'KRA MUSIC'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> listMusic = [
    new Music("Music 1", "Kra", "assets/un.jpg", "https://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Music("Music 2", "Jacob", "assets/deux.jpg", "https://codabee.com/wp-content/uploads/2018/06/deux.mp3")
  ];

  AudioPlayer audioPlayer;
  Music musicActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 0);
  PlayerState statut = PlayerState.stoped;
  StreamSubscription positionSub;
  StreamSubscription stateSubcription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    musicActuelle = listMusic[0];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(musicActuelle.imgPath),
              ),
            ),
            textStyle(musicActuelle.titre, 1.5),
            textStyle(musicActuelle.artiste, 1.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, Action.rewind),
                bouton((statut == PlayerState.playing) ? Icons.pause : Icons.play_arrow, 40.0,(statut == PlayerState.playing) ? Action.pause : Action.play),
                bouton(Icons.fast_forward, 30.0, Action.forward),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                textStyle("00:00", 0.8),
                textStyle("25:00", 0.8)
              ],
            ),
            new Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30,
                activeColor: Colors.red,
                inactiveColor: Colors.white,
                onChanged: (double d) {
                  setState(() {
                    Duration nouvelleDuration =
                        new Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                  });
                })
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Text textStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      style: TextStyle(
          color: Colors.white, fontSize: 20.0, fontStyle: FontStyle.italic),
    );
  }

  IconButton bouton(IconData icone, double taille, Action action) {
    return new IconButton(
        color: Colors.white,
        iconSize: taille,
        icon: Icon(icone),
        onPressed: () {
          switch (action) {
            case Action.play:
              print(statut);
              playing();
              break;
            case Action.pause:
              pause();
              break;
            case Action.forward:
              print("forward");
              break;
            case Action.rewind:
              print("rewind");
              break;
          }
        });
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer(); // creation de notre audio player
    // souscription à la position afin de mettre à jour notre slider
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    // voir on est en trian de jouer ou si on est en pause
    stateSubcription = audioPlayer.onAudioPositionChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stoped;
        });
      }
    }, onError: (message) => {print('error: $message'), setState(() {
       statut = PlayerState.stoped;
       duree = new Duration(seconds: 0);
       position = new Duration(seconds: 0);
    })});
  }

  Future playing () async {
    await audioPlayer.play(musicActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause () async{
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }
}

enum Action { play, pause, rewind, forward }

enum PlayerState { playing, stoped, paused }
