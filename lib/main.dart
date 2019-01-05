import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url         = "https://api.hgbrasil.com/finance?format=json&key=";
const hgKey       = "15886e27";
String requestUrl = url + hgKey;

void main () async {

  //print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
    )
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(requestUrl);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){

    if(text.isEmpty){
      dolarController.text = "";
      euroController.text = "";
    }

    double real = double.parse(text);
    dolarController.text = (real/dolar).toStringAsFixed(2);
    euroController.text = (real/euro).toStringAsFixed(2);


  }

  void _dolarChanged(String text){

    if(text.isEmpty){
      realController.text = "";
      euroController.text = "";
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text){

    if(text.isEmpty){
      realController.text = "";
      dolarController.text = "";
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Currency Converter",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                    "Loading...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            case ConnectionState.active:
            case ConnectionState.done:
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text(
                    "Error loading data!",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {

                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                debugPrint("Dolar: $dolar");
                debugPrint("Euro: $euro");

                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                      ),
                      Divider(),
                      buildTextFiled("Brazilian Real", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextFiled("Dolar", "US\$", dolarController, _dolarChanged),
                      Divider(),
                      buildTextFiled("Euro", "€", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        }
      ),
    );
  }
}

Widget buildTextFiled(String label, String prefix, TextEditingController controller, Function change){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.amber
        ),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber, fontSize: 25.0
    ),
    onChanged: change,
    keyboardType: TextInputType.number,
  );
}