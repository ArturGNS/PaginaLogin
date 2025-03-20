import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();

}

class _MainPageState extends State<MainPage> {
  PageController controller = PageController(initialPage: 0);
  int posicaoPagina = 0;
  @override
  Widget build (BuildContext content) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pagina Principal"),
        ),
        drawer: Drawer(
          
        ),
      )
    )
  }
  }
