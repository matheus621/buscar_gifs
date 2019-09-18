import 'dart:convert';

import 'package:buscar_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _busca;

  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_busca == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=JGUBwzk8Qvp07yDd8ByjzJzaD9VWCm6o&limit=20&rating=G");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=JGUBwzk8Qvp07yDd8ByjzJzaD9VWCm6o&q=$_busca&limit=19&offset=$_offset&rating=G&lang=en");
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.deepPurple),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.deepPurple, fontSize: 18.0),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              onSubmitted: (text) {
                setState(() {
                  _busca = text;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          return _createGifTable(context, snapshot);
                    }
                  }))
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_busca == null || _busca.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_busca == null || index < snapshot.data["data"].length)
            return GestureDetector(
                child: FadeInImage.memoryNetwork(placeholder: kTransparentImage,
                  image:
                  snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover),
                onTap: ()
          {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) => GifPage(snapshot.data["data"][index]))
            );
          },
          onLongPress: (){
          Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
          },
          );
          else
          return Container(
          child: GestureDetector(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Icon(
          Icons.add,
          color: Colors.deepPurple,
          size: 70.0,
          ),
          Text(
          "Carregar mais...",
          style:
          TextStyle(color: Colors.deepPurple, fontSize: 22.0),
          )
          ],
          ),
          onTap: () {
          setState(() {
          _offset += 19;
          });
          },
          )
          ,
          );
        });
  }
}
