import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';

import 'package:memoria/Objeto.dart';

void main() {
  runApp(Memoria());
}

class Memoria extends StatefulWidget {
  _MemoriaState createState() => _MemoriaState();
}

class _MemoriaState extends State<Memoria> {
  AudioCache audioCache = new AudioCache();
  AudioPlayer audioPlayer = new AudioPlayer();

  static const String HELP =
      "http://www.christineluken.com/wp-content/uploads/2016/05/Most-Important-Question-1024x1024.jpg";

  final title = 'Memória';
  Objeto _click1 = null;
  Objeto _click2 = null;
  List<String> iconesPadrao = null;
  List<String> iconesBase = null;
  List<String> icones = [];
  List<bool> acertos = null;
  static const String testDevice = 'ca-app-pub-1741287384517063~5435031724';
  InterstitialAd _interstitialAd;

  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
    nonPersonalizedAds: true,
  );

  _MemoriaState() {
    _novoJogo();
  }

  _novoJogo() {
    iconesPadrao = [HELP, HELP, HELP, HELP, HELP, HELP];
    iconesBase = [
      "https://images.theconversation.com/files/205966/original/file-20180212-58348-7huv6f.jpeg?ixlib=rb-1.1.0&q=45&auto=format&w=926&fit=clip",
      "https://www.cesarsway.com/sites/newcesarsway/files/styles/large_article_preview/public/Common-dog-behaviors-explained.jpg?itok=FSzwbBoi",
      "https://www.what-dog.net/Images/faces2/scroll001.jpg",
      "https://static.boredpanda.com/blog/wp-content/org_uploads/2014/06/cute-dog.jpg",
      "http://dognamesearch.com/wp-content/uploads/2014/05/puppy-sound-300x289.jpg",
      "https://c1.staticflickr.com/1/730/21225816748_c41918293d_b.jpg",
      "https://grist.files.wordpress.com/2012/01/daschund-dog-flickr-jonathan-gill-2.jpg"
    ];
    acertos = [false, false, false, false, false, false];
    icones = [];
    iconesBase.shuffle();
    icones.addAll(iconesBase.sublist(0, 3));
    icones.addAll(iconesBase.sublist(0, 3));
    icones.shuffle();
    print(icones);
  }

  InterstitialAd createInterstitialAd() {
    return new InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: GridView.count(
          crossAxisCount: 2,
          children: List.generate(6, (index) {
            return new Container(
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(3.0),
              child: new FlatButton(
                color: Colors.white,
                child: new ConstrainedBox(
                  constraints: new BoxConstraints.expand(),
                  child: new Image.network(
                    iconesPadrao[index],
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
                onPressed: () {
                  if (iconesPadrao[index] == HELP) {
                    setState(() {
                      iconesPadrao[index] = icones[index];
                    });
                    verificaClick(index, icones[index]);
                  }
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  play(String nome) async {
    audioCache.play(nome, volume: 1.0);
  }

  Future<Null> verificaClick(index, String icone) async {
    await new Future.delayed(const Duration(seconds: 1));

    if (_click1 == null && _click2 == null) {
      _click1 = new Objeto(indice: index, icone: icone);
    } else if (_click1 != null && _click2 == null) {
      _click2 = new Objeto(indice: index, icone: icone);
      if (_click1.icone == _click2.icone) {
        acertos[_click1.indice] = true;
        acertos[_click2.indice] = true;
        play('yes.wav');
      } else {
        play('erro.mp3');
      }
      _click1 = null;
      _click2 = null;

      bool acabou = true;
      acertos.asMap().forEach((i, acertou) {
        if (!acertou) {
          setState(() {
            iconesPadrao[i] = HELP;
            acabou = false;
          });
        }
      });
      if (acabou) {
        setState(() {
          _novoJogo();
          print("Novo JOGO");
          print("Inicio Propaganda");
          _interstitialAd?.dispose();
          _interstitialAd = createInterstitialAd()..load();
          _interstitialAd?.show();
          print("Fim Propaganda");
        });
      }
    }
    print(acertos);
  }
}
