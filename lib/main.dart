import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HttpApp(),
    );
  }
}

class HttpApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HttpAppState();
}

class _HttpAppState extends State<HttpApp> {
  String result = '';
  List data = [];
  TextEditingController _editingController = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        print('bottom');
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(hintText: '검색어를 입력하세요'),
        ),
      ),
      body: Stack(//stack을 한 이유는 floatingactionbutton을 양쪽에 2개 띄우고 싶어서 해봄
        children: [
          Center(
            child: data.length == 0
                ? Text(
                    '데이터가 없습니다.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )
                : ListView.builder(
                    itemBuilder: (context, index) {
                      return Card(
                        child: Container(
                          child: Row(
                            children: <Widget>[
                              Image.network(
                                data[index]['thumbnail'],
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                              Column(
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 150,
                                    child: Text(
                                      data[index]['title'].toString(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(data[index]['authors'].toString()),
                                  Text(data[index]['sale_price'].toString()),
                                  Text(data[index]['status'].toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: data.length,
                    controller: _scrollController,
                  ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton(
              onPressed: () {
                page = 1;
                data.clear();
                getJSONData();
              },
              child: Icon(Icons.file_download),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                //싼 가격순
                // data.sort((a, b) => a['sale_price'].compareTo(b['sale_price']));
                //
                //비싼 가격순
                // data.sort((a, b) => b['sale_price'].compareTo(a['sale_price']));
                //
                //정렬해보려다가 오류 발생한 코드
                // data.sort((a, b) => data[a]['sale_price'].compareTo(data[b]['sale_price'] ));
                // data.where((e) => e['sale_price'] >= 35000);

                print(data);
              },
              child: Icon(Icons.android),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getJSONData() async {
    var url =
        'http://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${_editingController.value.text}';
    var respone = await http.get(Uri.encodeFull(url),
        headers: {"Authorization": "KakaoAK 354092c41bfe1ad75fb1e3e47648b4ed"});

    setState(() {
      var dataConvertedToJSON = json.decode(respone.body);
      List result = dataConvertedToJSON['documents'];
      data.addAll(result);
      //싼 가격순
      data.sort((a, b) => a['sale_price'].compareTo(b['sale_price']));
      //
      // //비싼 가격순
      // data.sort((a, b) => b['sale_price'].compareTo(a['sale_price']));


    });


    return respone.body;
  }
}
