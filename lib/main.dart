import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TfLiteHome(),
      )
  );
}

class TfLiteHome extends StatefulWidget {
  @override
  _TfLiteHomeState createState() => _TfLiteHomeState();
}

class _TfLiteHomeState extends State<TfLiteHome> {
  File _image;

  bool busy = false;

  List _recognitions;

  var pokeInfo = {
    'Blastoise' : 'Blastoise is a Water-type Pokémon. It evolves from Wartortle. It is the final form of Squirtle',
    'Bulbasaur' : 'Bulbasaur is a dual-type Grass/Poison Pokémon. It evolves into Ivysaur, which evolves into Venusaur',
    'Charizard' : 'Charizard  is a dual-type Fire/Flying Pokémon.It evolves from Charmeleon. It is the final form of Charmander.',
    'Charmander' : 'Charmander is a Fire-type Pokémon.It evolves into Charmeleon, which evolves into Charizard',
    'Charmeleon' : 'Charmeleon is a Fire-type Pokémon. It evolves from Charmander and evolves into Charizard.',
    'Ivysaur' : 'Ivysaur is a dual-type Grass/Poison Pokémon .It evolves from Bulbasaur and evolves into Venusaur.',
    'Pikachu' : 'Pikachu is an Electric-type Pokémon .It evolves from Pichu when leveled up with high friendship and evolves into Raichu when exposed to a Thunder Stone.',
    'Raichu' : 'Raichu is an Electric-type Pokémon.It evolves from Pikachu when exposed to a Thunder Stone. It is the final form of Pichu.',
    'Squirtle' : 'Squirtle is a Water-type Pokémon. It evolves into Wartortle, which evolves into Blastoise.',
    'Venusaur' : 'Venusaur is a dual-type Grass/Poison Pokémon. It evolves from Ivysaur. It is the final form of Bulbasaur.',
    ' Wortortle' : 'Wartortle is a Water-type Pokémon. It evolves from Squirtle and evolves into Blastoise'
  };

  @override
  void initState() {
    super.initState();
    busy = true;
    loadModel().then((val) {
      setState(() {
        busy = false;
      });
    });
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
          model: 'assets/tflite/poke_predictor.tflite',
          labels: 'assets/tflite/labels.txt'
      );
    } on Exception catch (e) {
      print("couldn't load model");
      print(e);
    }
  }

  classifyImage(image) async{
    if(image==null)return;

    await customModel(image);

    setState(() {
      _image = image;
      busy = false;
    });
  }

  selectFromImagePicker() async{
    final picker = ImagePicker();
    var image = await picker.getImage(source: ImageSource.camera);
    if(image == null)return;
    setState(() {
      busy = true;
    });
    //using "image" which is "picked file" and making it into "file" in "_image"
    File _image = File(image.path);
    classifyImage(_image);
  }



  customModel(image) async{
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 2,
    );
    setState(() {
      _recognitions = recognitions;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: Text('Pokedex'),
          centerTitle: true,
          backgroundColor: Colors.blue[800],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.image),
          tooltip: 'pick image from gallery',
          onPressed: selectFromImagePicker,
        ),
        body: busy
            ? Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
            : Container(

          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _image == null ? Container() : Center(child: Image.file(_image,height: 300.0,width: 300,)),  //
              SizedBox(
                height: 10.0,
              ),
              _recognitions != null
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Pokemon : ${_recognitions[0]["label"].substring(2,)}", //
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10.0,),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "${pokeInfo[_recognitions[0]["label"].substring(2,)]}",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                ],
              )
                  : Container()
            ],
          ),

        )
    );
  }

}